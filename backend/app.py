from flask import Flask, request, jsonify
from flask_cors import CORS
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from dotenv import load_dotenv
import logging
import json
from openai import OpenAI

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

# OpenAI configuration (for AI quiz generation)
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
openai_client = OpenAI(api_key=OPENAI_API_KEY) if OPENAI_API_KEY else None

logger.info("📧 Flask OTP Server Started")
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

@app.route('/generate-quiz', methods=['POST', 'OPTIONS'])
def generate_quiz():
    """
    Generate a multiple-choice quiz from pasted notes using OpenAI.

    Request body:
    {
        "notes": "full text notes...",
        "difficulty": "Easy|Medium|Hard",
        "numQuestions": 10
    }

    Response:
    {
        "title": "string",
        "questions": [
            {
                "question": "string",
                "options": ["A", "B", "C", "D"],
                "correctAnswer": 0
            }
        ]
    }
    """
    if request.method == 'OPTIONS':
        return '', 204

    if openai_client is None:
        logger.error("❌ OPENAI_API_KEY is not configured")
        return jsonify({'error': 'OpenAI API key not configured on server'}), 500

    try:
        data = request.get_json(silent=True) or {}
        notes = (data.get('notes') or '').strip()
        difficulty = (data.get('difficulty') or 'Medium').strip()
        num_questions = int(data.get('numQuestions') or 10)

        if not notes:
            return jsonify({'error': 'notes is required'}), 400

        num_questions = max(3, min(num_questions, 25))

        logger.info(f"🧠 Generating quiz | difficulty={difficulty}, num={num_questions}")

        system_prompt = (
            "You are an expert quiz generator for a learning app. "
            "Given raw study notes, you create clear multiple-choice questions "
            "that help users test their understanding."
        )

        user_prompt = f"""
Generate exactly {num_questions} multiple-choice questions from the student's notes below.

Difficulty: {difficulty}

Return ONLY valid JSON in this exact shape, with no extra text:
{{
  "title": "Short quiz title based on the topic",
  "questions": [
    {{
      "question": "Question text",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctAnswer": 0
    }}
  ]
}}

Rules:
- Only 4 options per question.
- correctAnswer is the zero-based index of the correct option.
- Questions must be answerable from the notes.
- Use simple, clear English.

Notes:
{notes}
"""

        completion = openai_client.responses.create(
            model="gpt-4.1-mini",
            input=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
            response_format={"type": "json_object"},
        )

        try:
            content = completion.output[0].content[0].text
        except Exception as parse_err:
            logger.error(f"❌ Unexpected OpenAI response format: {parse_err}")
            logger.debug(f"Raw completion: {completion}")
            return jsonify({'error': 'Unexpected AI response format'}), 500

        try:
            quiz = json.loads(content)
        except json.JSONDecodeError as json_err:
            logger.error(f"❌ Failed to decode AI JSON: {json_err}")
            logger.debug(f"AI content: {content}")
            return jsonify({'error': 'AI returned invalid JSON'}), 500

        # Basic validation
        if 'questions' not in quiz or not isinstance(quiz['questions'], list):
            return jsonify({'error': 'AI response missing questions'}), 500

        logger.info(f"✅ Generated quiz with {len(quiz['questions'])} questions")
        return jsonify(quiz), 200

    except Exception as e:
        logger.error(f"❌ Error generating quiz: {str(e)}")
        return jsonify({'error': f'Error generating quiz: {str(e)}'}), 500

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
