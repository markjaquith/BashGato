![BashGato](https://user-images.githubusercontent.com/353790/199152451-6f177acb-7621-4d39-ac08-bf56d9f6d572.png)

BashGato is a Bash script that can control Elgato lights like the Key Light, Key Light Air, Key Light Mini, and Light Strip.

The best way to use this is to pair it with a clickable rotary dial, where click is mapped to `toggle`, and the dial controls `up` and `down`.

I use Alfred to do this in macOS, but any app that lets you run a bash script based on a keyboard macro will work.

## Usage

- `./control.sh on` Turn the lights on.
- `./control.sh off` Turn the lights off.
- `./control.sh toggle` Toggle the lights.
- `./control.sh up` Turn the brightness up.
- `./control.sh down` Turn the brightness down.

## Requirements

I think just Bash and cURL.

## Configuration

At the top of `control.sh` you will see a bunch of variables you can configure. The one thing you will have to change is the IP address of your lights.

You can find this by looking at the settings for your light in the Elgato Control Center app.

Multiple lights can be configured. They will be controlled in tandem, but the light strips can also have a hardcoded brightness, or a brightness that is a percentage of the main brightness. You may want your light strips to max out when your main lights are at medium brightness, but have them start to dim when your main lights reach low brightness.

## Alfred Configuration

Set up a new workflow that triggers the "Run Script" action, and choose 
"External Script", picking `control.sh`. Pass one of the 5 commands.

Note that you should enable "Trigger behavior > Pass through modifier keys (fastest)" or else the commands will take about 200ms to complete and a rotary knob won't feel "realtime".

<img width="827" alt="CleanShot 2022-10-31 at 23 39 47@2x" src="https://user-images.githubusercontent.com/353790/199153566-37a2ff90-04d2-4f47-873f-cdd88da60bc2.png">
