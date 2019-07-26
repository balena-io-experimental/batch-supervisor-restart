const Balena = require('balena-sdk');
const Bluebird = require('bluebird')
const deviceStatus = require('balena-device-status');
const authToken = process.env.APIKEY;

if (!authToken) {
    console.error("Please set the APIKEY environment variable!")
    process.exit(1)
}

const balena = new Balena();
balena.auth.loginWithToken(authToken, function (error) {
    if (error)
        throw error;
});

const main = async function(appId, statusKey) {
    // Print out all the device UUIDs with "updating" status
    let devices = await balena.models.device.getAllByApplication(appId, {$filter: {is_online: true}});
    const details = await Bluebird.map(devices, async (d, idx) => {
        const device = await balena.models.device.getWithServiceDetails(d.uuid)
        let status = deviceStatus.getStatus(device);
        if (status && status.key === statusKey) {
            console.log(`${device.uuid}`)
        }
    }, { concurrency: 5 });
}

if (process.argv[2]) {
    let appId = parseInt(process.argv[2])
    if (!isNaN(appId)) {
        main(appId, "updating")
    } else{
        console.error("AppId is not a number, please check.")
        process.exit(1)
    }
} else {
    console.error("Please plass the appId as a command line argument.")
}
