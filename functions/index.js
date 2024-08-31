/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.deleteInactiveRooms = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    //현재와 5시간 계산
    const cutoff = new Date();
    cutoff.setHours(cutoff.getHours() - 5);
    const roomsRef = admin.firestore().collection('rooms');
    const query = roomsRef.where('lastActiveAt', '<=', cutoff);
    const snapshot = await query.get();
    snapshot.forEach(doc => {
    doc.ref.delete().then(()=>{
        console.log(`deleted room: ${doc.id}`);
    }).catch(error => {
        console.error(`failed to delete room: ${doc.id}`,error);
    });
    });
    return null;
})

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
