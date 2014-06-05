# Pusher Diagnostics iOS

iOS app for developers to test connections to [Pusher's](http://pusher.com/) realtime messaging platform. 
Available on the [AppStore](https://itunes.apple.com/us/app/pusher-diagnostics/id622538006).

## Features
- Test the connection to Pusher on the device 
- Test secure and non-secure connections over SSL 
- Test connection behaviour over WiFi and mobile networks 
- Test automatic reconnection when internet connectivity is lost 
- Test automatic reconnection if the app is backgrounded 

## Installation

First off, make sure you have Xcode installed and updated. Then [install CocoaPods](http://guides.cocoapods.org/using/getting-started.html) if you haven't already got it (requires Ruby):

```
sudo gem install cocoapods
```

The next step is to clone this repository (or [download as a zip](https://github.com/pusher/pusher-test-iOS/archive/master.zip)) and open a terminal window into the repository directory:

```
cd /path/to/pusher-test-iOS
```

Install the necessary dependencies by running CocoaPods:

```
pod install
```

When done, open the `Diagnostics.xcworkspace` file in Xcode and make sure everything is working by building and running the application (Cmd + R). The application will open and run in the iOS Simulator.

If you experience any errors then perform the suggested tasks and fixes in Xcode before submitting a support request or GitHub issue.