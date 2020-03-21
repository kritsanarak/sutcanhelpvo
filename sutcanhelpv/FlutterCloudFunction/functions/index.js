const functions = require('firebase-functions');
const admin = require('firebase-admin');
 
admin.initializeApp(functions.config().functions);
 
var newData;
 
exports.myTrigger = functions.firestore.document('SOS/{id}').onCreate(async (snapshot, context) => {
    //
 
    if (snapshot.empty) {
        console.log('No Devices');
        return;
    }
 
    newData = snapshot.data();
 
    const deviceIdTokens = await admin
        .firestore()
        .collection('DeviceTokens')
        .get();
 
    var tokens = [];
 
    for (var token of deviceIdTokens.docs) {
        tokens.push(token.data().device_Tokens);
    }
    var payload = {
        notification: {
            title: 'SUTCANHELP',
            body: newData.อาการ,
            sound: 'default',
        },
        data: { click_action: 'FLUTTER_NOTIFICATION_CLICK', message: newData.อาการ},
    };
 
    try {
        const response = await admin.messaging().sendToDevice(tokens, payload);
        console.log('Notification sent successfully');
    } catch (err) {
        console.log('Error sending Application');
    }
});
