import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();

/**
 * Generate dynamic sharing captions based on user data and content type
 */
export const generateSharingCaption = functions.https.onCall(async (data, context) => {
  try {
    const { type, userId, customMessage, metadata } = data;

    // Authenticate user
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Get user profile for personalization
    const userDoc = await db.collection('users').doc(userId).get();
    const userData = userDoc.data();

    let caption = '';

    switch (type) {
      case 'baby_result':
        caption = await generateBabyResultCaption(userData, metadata);
        break;
      case 'quiz_result':
        caption = await generateQuizResultCaption(userData, metadata);
        break;
      case 'app_invitation':
        caption = await generateAppInvitationCaption(userData);
        break;
      case 'instagram_post':
        caption = await generateInstagramCaption(userData, metadata);
        break;
      case 'whatsapp_message':
        caption = await generateWhatsAppCaption(userData, metadata);
        break;
      default:
        caption = customMessage || 'Check out this amazing app! ✨';
    }

    // Log caption generation for analytics
    await db.collection('caption_generations').add({
      userId,
      type,
      caption,
      metadata,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { caption };
  } catch (error) {
    console.error('Error generating caption:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate caption');
  }
});

/**
 * Generate viral sharing links with tracking
 */
export const generateSharingLink = functions.https.onCall(async (data, context) => {
  try {
    const { userId, contentType, contentId, metadata } = data;

    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Generate unique sharing ID
    const sharingId = `${userId}_${contentType}_${Date.now()}`;
    
    // Store sharing link data
    await db.collection('sharing_links').doc(sharingId).set({
      userId,
      contentType,
      contentId,
      metadata,
      clicks: 0,
      conversions: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Generate dynamic link (simplified version)
    const baseUrl = 'https://futurebaby.app';
    const link = `${baseUrl}?share=${sharingId}&ref=${userId}`;

    return { link, sharingId };
  } catch (error) {
    console.error('Error generating sharing link:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate sharing link');
  }
});

/**
 * Track sharing link clicks and conversions
 */
export const trackSharingClick = functions.https.onCall(async (data, context) => {
  try {
    const { sharingId, clickerId, action } = data; // action: 'click' | 'install' | 'signup'

    // Update sharing link stats
    const sharingRef = db.collection('sharing_links').doc(sharingId);
    
    if (action === 'click') {
      await sharingRef.update({
        clicks: admin.firestore.FieldValue.increment(1),
        lastClickAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else if (action === 'install' || action === 'signup') {
      await sharingRef.update({
        conversions: admin.firestore.FieldValue.increment(1),
        lastConversionAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Reward the sharer
      const sharingDoc = await sharingRef.get();
      const sharingData = sharingDoc.data();
      
      if (sharingData) {
        await db.collection('users').doc(sharingData.userId).update({
          referralRewards: admin.firestore.FieldValue.increment(10),
          totalReferrals: admin.firestore.FieldValue.increment(1),
        });
      }
    }

    // Log the event
    await db.collection('sharing_events').add({
      sharingId,
      clickerId,
      action,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  } catch (error) {
    console.error('Error tracking sharing click:', error);
    throw new functions.https.HttpsError('internal', 'Failed to track sharing click');
  }
});

/**
 * Generate personalized baby result captions
 */
async function generateBabyResultCaption(userData: any, metadata: any): Promise<string> {
  const captions = [
    `Look at our adorable future baby! 👶✨ Can't wait to meet this little angel!`,
    `Our future bundle of joy looks amazing! 🌟 This is what love creates! 💕`,
    `Future family goals right here! 👨‍👩‍👧‍👦 So excited for this journey!`,
    `This is what our baby might look like! 😍 Already so much love for this little one!`,
    `Our hearts are melting! 💕 This future baby is going to be so loved! 👶`,
  ];

  // Personalize based on user data
  const userName = userData?.displayName || userData?.firstName;
  if (userName) {
    return `${userName} and partner's future baby is absolutely adorable! 👶✨ Can't wait to meet this little miracle! 💕`;
  }

  return captions[Math.floor(Math.random() * captions.length)];
}

/**
 * Generate personalized quiz result captions
 */
async function generateQuizResultCaption(userData: any, metadata: any): Promise<string> {
  const { quizTitle, score, totalQuestions, percentage } = metadata;
  
  if (percentage >= 90) {
    return `Nailed it! 🎯 Got ${score}/${totalQuestions} on "${quizTitle}" quiz! I'm a quiz master! 🏆`;
  } else if (percentage >= 70) {
    return `Pretty good! 😊 Scored ${score}/${totalQuestions} on "${quizTitle}" quiz! Getting better every time! 📈`;
  } else {
    return `Had so much fun with the "${quizTitle}" quiz! 🎮 Got ${score}/${totalQuestions} - time to practice more! 💪`;
  }
}

/**
 * Generate app invitation captions
 */
async function generateAppInvitationCaption(userData: any): Promise<string> {
  const invitations = [
    `Found this amazing app that shows what your future baby might look like! 👶 You have to try it!`,
    `This baby face generator is incredible - so much fun with your partner! ✨ Check it out!`,
    `Just discovered the cutest app for couples planning their future! 💕 You'll love it!`,
    `This app predicted our future baby and it's adorable! 🌟 Perfect for couples!`,
  ];

  return invitations[Math.floor(Math.random() * invitations.length)];
}

/**
 * Generate Instagram-optimized captions
 */
async function generateInstagramCaption(userData: any, metadata: any): Promise<string> {
  return `Our future little one! 👶✨ Can't wait to meet this angel 💕 
  
#FutureBaby #BabyFace #CoupleGoals #Love #Family #BabyPrediction #AI #Technology #Cute #Adorable`;
}

/**
 * Generate WhatsApp-friendly captions
 */
async function generateWhatsAppCaption(userData: any, metadata: any): Promise<string> {
  return `👶 Look what our future baby might look like! Isn't this amazing? 💕 
  
This app is so cool - it uses AI to predict how your baby will look! You should try it with your partner! 🌟`;
}

/**
 * Clean up old sharing data (runs daily)
 */
export const cleanupSharingData = functions.pubsub.schedule('0 2 * * *').onRun(async (context) => {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  // Clean up old sharing events
  const oldEvents = await db.collection('sharing_events')
    .where('timestamp', '<', thirtyDaysAgo)
    .get();

  const batch = db.batch();
  oldEvents.docs.forEach(doc => {
    batch.delete(doc.ref);
  });

  await batch.commit();
  console.log(`Cleaned up ${oldEvents.size} old sharing events`);
});

/**
 * Generate sharing analytics report (runs weekly)
 */
export const generateSharingReport = functions.pubsub.schedule('0 9 * * 1').onRun(async (context) => {
  const oneWeekAgo = new Date();
  oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

  // Get sharing stats for the week
  const sharingEvents = await db.collection('sharing_events')
    .where('timestamp', '>=', oneWeekAgo)
    .get();

  const stats = {
    totalShares: sharingEvents.size,
    platforms: {} as any,
    contentTypes: {} as any,
    topSharers: {} as any,
  };

  sharingEvents.docs.forEach(doc => {
    const data = doc.data();
    
    // Platform stats
    stats.platforms[data.platform] = (stats.platforms[data.platform] || 0) + 1;
    
    // Content type stats
    stats.contentTypes[data.contentType] = (stats.contentTypes[data.contentType] || 0) + 1;
    
    // Top sharers
    stats.topSharers[data.userId] = (stats.topSharers[data.userId] || 0) + 1;
  });

  // Store weekly report
  await db.collection('sharing_reports').add({
    weekOf: oneWeekAgo,
    stats,
    generatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log('Generated weekly sharing report:', stats);
});