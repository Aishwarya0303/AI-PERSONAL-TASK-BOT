const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Gmail credentials
const gmailEmail = "aishwaryakk72@gmail.com";
const gmailPassword = "ikpl brez gryx yvut"; // 16 digit app password

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

// Check and send scheduled emails every minute
exports.sendScheduledEmails = functions.pubsub
  .schedule("every 1 minutes")
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const db = admin.firestore();

    // Get all pending emails due now
    const snapshot = await db
      .collection("scheduled_emails")
      .where("status", "==", "pending")
      .where("scheduledTime", "<=", now)
      .get();

    if (snapshot.empty) {
      console.log("No emails to send");
      return null;
    }

    const promises = snapshot.docs.map(async (doc) => {
      const emailData = doc.data();

      const mailOptions = {
        from: `AI Task Bot <${gmailEmail}>`,
        to: emailData.recipientEmail,
        subject: emailData.subject,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #6B3A2A, #8B5E3C); padding: 30px; border-radius: 12px 12px 0 0;">
              <h1 style="color: white; margin: 0; font-size: 24px;">AI Task Bot</h1>
              <p style="color: rgba(255,255,255,0.8); margin: 5px 0 0;">Scheduled Email</p>
            </div>
            <div style="background: #FDF8F5; padding: 30px; border-radius: 0 0 12px 12px;">
              <p style="color: #2C1810; font-size: 16px; line-height: 1.6;">
                ${emailData.body}
              </p>
              <hr style="border: 1px solid #E8D5C4; margin: 20px 0;">
              <p style="color: #9E7B65; font-size: 12px;">
                Sent by AI Task Bot • ${new Date().toLocaleString()}
              </p>
            </div>
          </div>
        `,
      };

      try {
        await transporter.sendMail(mailOptions);
        // Mark as sent
        await doc.ref.update({
          status: "sent",
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        console.log(`Email sent to ${emailData.recipientEmail}`);
      } catch (error) {
        // Mark as failed
        await doc.ref.update({
          status: "failed",
          error: error.message,
        });
        console.error("Error sending email:", error);
      }
    });

    await Promise.all(promises);
    return null;
  });

// Send email immediately (HTTP trigger)
exports.sendEmailNow = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Must be logged in"
    );
  }

  const mailOptions = {
    from: `AI Task Bot <${gmailEmail}>`,
    to: data.recipientEmail,
    subject: data.subject,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #6B3A2A, #8B5E3C); padding: 30px; border-radius: 12px 12px 0 0;">
          <h1 style="color: white; margin: 0;">AI Task Bot</h1>
        </div>
        <div style="background: #FDF8F5; padding: 30px; border-radius: 0 0 12px 12px;">
          <p style="color: #2C1810; font-size: 16px; line-height: 1.6;">
            ${data.body}
          </p>
          <hr style="border: 1px solid #E8D5C4; margin: 20px 0;">
          <p style="color: #9E7B65; font-size: 12px;">
            Sent by AI Task Bot • ${new Date().toLocaleString()}
          </p>
        </div>
      </div>
    `,
  };

  await transporter.sendMail(mailOptions);
  return { success: true };
});