from flask import Flask, request, jsonify
from flask_cors import CORS
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from dotenv import load_dotenv
import logging

load_dotenv()

app = Flask(__name__)
CORS(app)

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Email configuration
SENDER_EMAIL = os.getenv("SENDER_EMAIL", "your-email@gmail.com")
SENDER_PASSWORD = os.getenv("SENDER_PASSWORD", "your-app-password")
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587

logger.info(f"📧 Flask OTP Server Started")
logger.info(f"📧 Sender Email: {SENDER_EMAIL}")

@app.route('/send-otp', methods=['POST', 'OPTIONS'])
def send_otp():
    """
    Send OTP via email.
    
    Request body:
    {
        "email": "user@example.com",
        "otp": "123456"
    }
    """
    if request.method == 'OPTIONS':
        return '', 204

    try:
        logger.info(f"📧 Received OTP request: {request.get_json()}")
        
        data = request.json
        email = data.get('email')
        otp = data.get('otp')

        logger.info(f"📧 Email: {email}, OTP: {otp}")

        if not email or not otp:
            logger.warning("❌ Missing email or OTP")
            return jsonify({'status': 'error', 'message': 'Email and OTP are required'}), 400

        # Create email
        message = MIMEMultipart("alternative")
        message["Subject"] = "Your Quiz App Verification Code"
        message["From"] = SENDER_EMAIL
        message["To"] = email

        # HTML content
        html = f"""\
        <html>
            <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <h2 style="color: #4CAF50;">Email Verification</h2>
                <p>Hello,</p>
                <p>You requested a verification code for your Smart Quiz Account. Use the code below to complete your registration:</p>
                
                <div style="background-color: #f5f5f5; padding: 20px; text-align: center; border-radius: 8px; margin: 20px 0;">
                    <h1 style="color: #4CAF50; letter-spacing: 2px; margin: 0;">{otp}</h1>
                </div>
                
                <p><strong>Important:</strong></p>
                <ul>
                    <li>This code expires in 10 minutes</li>
                    <li>Never share this code with anyone</li>
                    <li>We will never ask for this code via email or phone</li>
                </ul>
                
                <p>If you didn't request this code, you can safely ignore this email.</p>
                
                <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;">
                <p style="color: #666; font-size: 12px;">© 2024-2026 Smart Quiz App. All rights reserved.</p>
            </body>
        </html>
        """

        part = MIMEText(html, "html")
        message.attach(part)

        logger.info(f"📧 Connecting to Gmail SMTP...")
        # Send email via Gmail SMTP
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            logger.info(f"📧 Logging in as {SENDER_EMAIL}...")
            server.login(SENDER_EMAIL, SENDER_PASSWORD)
            logger.info(f"📧 Sending email to {email}...")
            server.sendmail(SENDER_EMAIL, email, message.as_string())

        logger.info(f"✅ OTP email sent successfully to {email}")
        return jsonify({'status': 'success', 'message': 'OTP sent successfully'}), 200

    except smtplib.SMTPAuthenticationError as e:
        logger.error(f"❌ Gmail authentication failed: {str(e)}")
        logger.error(f"❌ Check SENDER_EMAIL and SENDER_PASSWORD in .env")
        return jsonify({'status': 'error', 'message': 'Email authentication failed. Check credentials.'}), 500
    except smtplib.SMTPException as e:
        logger.error(f"❌ SMTP error: {str(e)}")
        return jsonify({'status': 'error', 'message': f'SMTP error: {str(e)}'}), 500
    except Exception as e:
        logger.error(f"❌ Error sending email: {str(e)}")
        import traceback
        logger.error(traceback.format_exc())
        return jsonify({'status': 'error', 'message': f'Error sending email: {str(e)}'}), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint for debugging."""
    logger.info("📧 Health check requested")
    return jsonify({
        'status': 'ok', 
        'message': 'Flask OTP Server is running',
        'sender_email': SENDER_EMAIL
    }), 200

@app.route('/', methods=['GET'])
def index():
    """Root endpoint."""
    return jsonify({'message': 'Smart Quiz OTP API'}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
