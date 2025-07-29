-- Location: supabase/migrations/20250129200522_auth_with_trip_system.sql
-- Schema Analysis: Fresh project with authentication and trip management system
-- Integration Type: Complete schema creation
-- Dependencies: None (fresh migration)

-- 1. Extensions and Custom Types
CREATE TYPE public.user_role AS ENUM ('admin', 'premium', 'standard');
CREATE TYPE public.trip_status AS ENUM ('planning', 'active', 'completed', 'cancelled');
CREATE TYPE public.weather_alert_severity AS ENUM ('minor', 'moderate', 'severe', 'extreme');

-- 2. Core Tables - User Management
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'standard'::public.user_role,
    avatar_url TEXT,
    preferred_currency TEXT DEFAULT 'USD',
    preferred_temperature_unit TEXT DEFAULT 'celsius',
    onboarding_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Trip Management Tables
CREATE TABLE public.trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    destination TEXT NOT NULL,
    destination_country TEXT,
    destination_coordinates POINT,
    trip_type TEXT NOT NULL,
    status public.trip_status DEFAULT 'planning'::public.trip_status,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    traveler_count INTEGER DEFAULT 1,
    budget DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Packing Lists and Items
CREATE TABLE public.packing_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    icon TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_system_category BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.packing_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.packing_categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    quantity INTEGER DEFAULT 1,
    is_packed BOOLEAN DEFAULT false,
    priority INTEGER DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Weather Alerts
CREATE TABLE public.weather_alerts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE,
    alert_type TEXT NOT NULL,
    severity public.weather_alert_severity NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Location Search History
CREATE TABLE public.location_searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    search_query TEXT NOT NULL,
    selected_location TEXT NOT NULL,
    location_coordinates POINT,
    country TEXT,
    search_count INTEGER DEFAULT 1,
    last_searched_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_trips_user_id ON public.trips(user_id);
CREATE INDEX idx_trips_status ON public.trips(status);
CREATE INDEX idx_trips_dates ON public.trips(start_date, end_date);
CREATE INDEX idx_packing_items_trip_id ON public.packing_items(trip_id);
CREATE INDEX idx_packing_items_category_id ON public.packing_items(category_id);
CREATE INDEX idx_weather_alerts_trip_id ON public.weather_alerts(trip_id);
CREATE INDEX idx_weather_alerts_active ON public.weather_alerts(is_active);
CREATE INDEX idx_location_searches_user_id ON public.location_searches(user_id);

-- 8. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.packing_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.packing_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weather_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_searches ENABLE ROW LEVEL SECURITY;

-- 9. Helper Functions for RLS
CREATE OR REPLACE FUNCTION public.is_trip_owner(trip_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.trips t
    WHERE t.id = trip_uuid AND t.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_packing_item(item_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.packing_items pi
    JOIN public.trips t ON pi.trip_id = t.id
    WHERE pi.id = item_uuid AND t.user_id = auth.uid()
)
$$;

CREATE OR REPLACE FUNCTION public.can_access_weather_alert(alert_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.weather_alerts wa
    JOIN public.trips t ON wa.trip_id = t.id
    WHERE wa.id = alert_uuid AND t.user_id = auth.uid()
)
$$;

-- 10. RLS Policies
CREATE POLICY "users_own_profile" ON public.user_profiles
FOR ALL TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

CREATE POLICY "users_manage_own_trips" ON public.trips
FOR ALL TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "public_read_packing_categories" ON public.packing_categories
FOR SELECT TO authenticated
USING (true);

CREATE POLICY "admin_manage_packing_categories" ON public.packing_categories
FOR ALL TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

CREATE POLICY "users_manage_own_packing_items" ON public.packing_items
FOR ALL TO authenticated
USING (public.can_access_packing_item(id))
WITH CHECK (public.can_access_packing_item(id));

CREATE POLICY "users_access_own_weather_alerts" ON public.weather_alerts
FOR ALL TO authenticated
USING (public.can_access_weather_alert(id))
WITH CHECK (public.can_access_weather_alert(id));

CREATE POLICY "users_manage_own_location_searches" ON public.location_searches
FOR ALL TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 11. Automatic Profile Creation Function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'standard'::public.user_role)
  );
  RETURN NEW;
END;
$$;

-- 12. Trigger for New User Creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 13. Update Timestamp Functions
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_trips_updated_at
    BEFORE UPDATE ON public.trips
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_packing_items_updated_at
    BEFORE UPDATE ON public.packing_items
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- 14. Default Packing Categories
DO $$
BEGIN
    INSERT INTO public.packing_categories (id, name, icon, sort_order, is_system_category) VALUES
        (gen_random_uuid(), 'Clothing', 'checkroom', 1, true),
        (gen_random_uuid(), 'Electronics', 'devices', 2, true),
        (gen_random_uuid(), 'Toiletries', 'soap', 3, true),
        (gen_random_uuid(), 'Documents', 'description', 4, true),
        (gen_random_uuid(), 'Medical', 'medical_services', 5, true),
        (gen_random_uuid(), 'Entertainment', 'sports_esports', 6, true),
        (gen_random_uuid(), 'Food & Snacks', 'restaurant', 7, true),
        (gen_random_uuid(), 'Miscellaneous', 'inventory_2', 8, true);
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Packing categories already exist, skipping insertion';
END $$;

-- 15. Sample Data for Testing
DO $$
DECLARE
    user1_id UUID := gen_random_uuid();
    user2_id UUID := gen_random_uuid();
    trip1_id UUID := gen_random_uuid();
    category1_id UUID;
    category2_id UUID;
BEGIN
    -- Create test auth users with complete field structure
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (user1_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'demo@packbuddy.com', crypt('packbuddy123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Demo User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user2_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'premium@packbuddy.com', crypt('packbuddy123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Premium User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Get existing category IDs
    SELECT id INTO category1_id FROM public.packing_categories WHERE name = 'Clothing' LIMIT 1;
    SELECT id INTO category2_id FROM public.packing_categories WHERE name = 'Electronics' LIMIT 1;

    -- Create sample trip
    INSERT INTO public.trips (id, user_id, destination, trip_type, start_date, end_date, traveler_count)
    VALUES (trip1_id, user1_id, 'Paris, France', 'leisure', CURRENT_DATE + INTERVAL '7 days', CURRENT_DATE + INTERVAL '14 days', 2);

    -- Create sample packing items
    INSERT INTO public.packing_items (trip_id, category_id, name, quantity, is_packed)
    VALUES
        (trip1_id, category1_id, 'T-shirts', 5, false),
        (trip1_id, category1_id, 'Jeans', 2, true),
        (trip1_id, category2_id, 'Phone Charger', 1, false),
        (trip1_id, category2_id, 'Camera', 1, false);

    -- Create sample weather alert
    INSERT INTO public.weather_alerts (trip_id, alert_type, severity, title, description, start_time, end_time)
    VALUES (
        trip1_id, 
        'thunderstorm', 
        'moderate'::public.weather_alert_severity,
        'Thunderstorm Warning',
        'Thunderstorms are expected in the Paris area. Pack waterproof clothing and consider indoor activities.',
        CURRENT_TIMESTAMP + INTERVAL '2 days',
        CURRENT_TIMESTAMP + INTERVAL '3 days'
    );

    -- Create sample location searches
    INSERT INTO public.location_searches (user_id, search_query, selected_location, country)
    VALUES
        (user1_id, 'paris', 'Paris, France', 'France'),
        (user1_id, 'london', 'London, United Kingdom', 'United Kingdom');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error during sample data creation: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error during sample data creation: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error during sample data creation: %', SQLERRM;
END $$;