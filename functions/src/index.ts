import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const onNotificationCreated = functions.firestore
  .document("users/{userId}/notifications/{notificationId}")
  .onCreate(async (snapshot, context) => {
    const notificationData = snapshot.data();
    const userId = context.params.userId;

    if (!notificationData) {
      console.log("No notification data found.");
      return null;
    }

    // Don't send push notification if the sender and recipient are the same
    if (notificationData.senderId === userId) {
      console.log("Sender and recipient are the same. Not sending push.");
      return null;
    }

    try {
      // Get the user's FCM token
      const userDoc = await admin.firestore().collection("users").doc(userId).get();
      if (!userDoc.exists) {
        console.log(`User ${userId} not found.`);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData?.fcmToken;

      if (!fcmToken) {
        console.log(`No FCM token found for user ${userId}.`);
        return null;
      }

      // Build the notification payload
      const senderUsername = notificationData.senderUsername || "Someone";
      const type = notificationData.type;

      let title = "Lumi Notification";
      let body = `${senderUsername} interacted with your profile.`;

      if (type === "like") {
        title = "New Like";
        body = `${senderUsername} liked your post.`;
      } else if (type === "comment") {
        title = "New Comment";
        const commentSnippet = (notificationData.commentText && notificationData.commentText.length > 30)
          ? `${notificationData.commentText.substring(0, 30)}...`
          : notificationData.commentText;
        body = `${senderUsername} commented: "${commentSnippet || ""}"`;
      } else if (type === "follow") {
        title = "New Follower";
        body = `${senderUsername} started following you.`;
      }

      const message: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: type || "unknown",
          notificationId: snapshot.id,
          senderId: notificationData.senderId || "",
          postId: notificationData.postId || "",
        },
        // Setup APNs for iOS background push properly
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      // Send the message
      const response = await admin.messaging().send(message);
      console.log(`Successfully sent push notification to ${userId}:`, response);

      return null;
    } catch (error) {
      console.error("Error sending push notification:", error);
      return null;
    }
  });
