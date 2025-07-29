import { serve } from "https://deno.land/std@0.192.0/http/server.ts";

serve(async (req) => {
  // ✅ CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization"
      }
    });
  }
  
  try {
    const { email, fullName } = await req.json();
    
    // Validate required fields
    if (!email || !fullName) {
      throw new Error("Email and fullName are required");
    }
    
    // Get Resend API key from environment
    const resendApiKey = Deno.env.get('RESEND_API_KEY');
    if (!resendApiKey) {
      throw new Error("RESEND_API_KEY not configured");
    }
    
    // Prepare welcome email content
    const emailContent = {
      from: "onboarding@resend.dev",
      to: email,
      subject: "🎒 Welcome to PackBuddy - Your Travel Companion!",
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Welcome to PackBuddy</title>
          <style>
            body { font-family: 'Inter', Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 0; background-color: #f8fafc; }
            .container { max-width: 600px; margin: 0 auto; background-color: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px 30px; text-align: center; }
            .header h1 { margin: 0; font-size: 28px; font-weight: 700; }
            .header .tagline { margin: 10px 0 0; font-size: 16px; opacity: 0.9; }
            .content { padding: 40px 30px; }
            .greeting { font-size: 18px; margin-bottom: 20px; color: #4a5568; }
            .feature-list { list-style: none; padding: 0; margin: 30px 0; }
            .feature-list li { padding: 12px 0; border-bottom: 1px solid #e2e8f0; display: flex; align-items: center; }
            .feature-list li:last-child { border-bottom: none; }
            .feature-icon { font-size: 20px; margin-right: 15px; width: 30px; text-align: center; }
            .cta-button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 30px; border-radius: 8px; text-decoration: none; font-weight: 600; margin: 30px 0; }
            .footer { background-color: #f7fafc; padding: 30px; text-align: center; color: #718096; font-size: 14px; }
            .social-links { margin: 20px 0; }
            .social-links a { color: #667eea; margin: 0 10px; text-decoration: none; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>🎒 Welcome to PackBuddy!</h1>
              <p class="tagline">Your intelligent travel packing companion</p>
            </div>
            
            <div class="content">
              <p class="greeting">Hello ${fullName}! 👋</p>
              
              <p>Welcome to the PackBuddy family! We are thrilled to have you on board. Get ready to revolutionize the way you pack for your adventures.</p>
              
              <h3>🌟 What makes PackBuddy special?</h3>
              <ul class="feature-list">
                <li>
                  <span class="feature-icon">🌤️</span>
                  <span><strong>Weather-Smart Packing:</strong> Get packing suggestions based on real-time weather forecasts and alerts</span>
                </li>
                <li>
                  <span class="feature-icon">📋</span>
                  <span><strong>Intelligent Lists:</strong> Create comprehensive packing lists tailored to your destination and trip type</span>
                </li>
                <li>
                  <span class="feature-icon">🗺️</span>
                  <span><strong>Global Destinations:</strong> Search and plan for any destination worldwide with location-based insights</span>
                </li>
                <li>
                  <span class="feature-icon">📱</span>
                  <span><strong>Progress Tracking:</strong> Never forget an item with our intuitive packing progress tracker</span>
                </li>
                <li>
                  <span class="feature-icon">⚡</span>
                  <span><strong>Quick Setup:</strong> Get started in minutes with our streamlined trip creation process</span>
                </li>
              </ul>
              
              <h3>🚀 Ready to start your first trip?</h3>
              <p>Your account is ready to go! Open the PackBuddy app and create your first trip to experience the magic of intelligent packing.</p>
              
              <div style="text-align: center;">
                <a href="#" class="cta-button">Start Packing Smart 🎯</a>
              </div>
              
              <h3>💡 Pro Tips for New Users:</h3>
              <ul>
                <li>📅 <strong>Plan Ahead:</strong> Create your trip as soon as you book to get the most accurate weather forecasts</li>
                <li>🎯 <strong>Use Categories:</strong> Organize your items by category for better packing efficiency</li>
                <li>⚠️ <strong>Check Weather Alerts:</strong> Keep an eye on weather warnings to adjust your packing list</li>
                <li>🌍 <strong>Explore Locations:</strong> Use our global search to discover packing insights for any destination</li>
              </ul>
            </div>
            
            <div class="footer">
              <p><strong>Need help getting started?</strong></p>
              <p>Our support team is here to help! Reply to this email with any questions.</p>
              <div class="social-links">
                <a href="#">📧 Support</a> |
                <a href="#">📖 Help Center</a> |
                <a href="#">🌐 Website</a>
              </div>
              <p style="margin-top: 20px; font-size: 12px;">
                Happy travels!<br>
                The PackBuddy Team 🎒✈️
              </p>
            </div>
          </div>
        </body>
        </html>
      `
    };
    
    // Send email via Resend API
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${resendApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(emailContent)
    });
    
    if (!response.ok) {
      const errorData = await response.text();
      throw new Error(`Resend API error: ${response.status} ${errorData}`);
    }
    
    const result = await response.json();
    
    return new Response(JSON.stringify({
      success: true,
      message: "Welcome email sent successfully",
      emailId: result.id
    }), {
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      }
    });
    
  } catch (error) {
    return new Response(JSON.stringify({
      error: error.message,
      success: false
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      }
    });
  }
});