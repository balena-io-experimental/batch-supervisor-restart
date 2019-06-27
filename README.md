## Batch tasks on balena devices

Running the script `task.sh` on a set of devices.

* ensure that `task.sh` has the exact task that you need to do (here it's restarting the supervisor)
* add the list of devices to a file called `batch`
* log in with the CLI as `balena login` with the correct user that has access to those devices
* run `./run.sh` to iterate through the devices in `batch`, connect to them, and run the task inside the host OS

