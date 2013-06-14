# SJNotificationViewController #

SJNotificationViewController lets you put dead-simple notifications that slide up from the bottom or down from the top of a view into your iOS apps.

All you need to do is create a notification, give it a view to slide up from, and tell it to show itself. Like this:

	SJNotificationViewController *notificationController = [[SJNotificationViewController alloc] initWithNibName:@"SJNotificationViewController" bundle:nil];
	[notificationController setParentView:aView];
	[notificationController setNotificationTitle:@"Hello"];
	[notificationController show];
	
![](http://www.judoburrito.com/SJNotificationViewController/notification.png)
	
That gives you a basic notification that slides up from the bottom of `aView`. When you want your notification to slide back down, you just call `[notificationController hide]`. Pretty simple, right?

You can customise a few things about SJNotificationViewController:
    
## Notification Levels ##

SJNotificationViewController has a property called `notificationLevel` that changes the notification's background colour. A notification's `notificationLevel` is one of `SJNotificationLevelError` (red -- for error notifications), `SJNotificationLevelMessage` (blue -- for regular notifications), or `SJNotificationLevelSuccess` (green -- for success notifications). The exact RGB values for the notification levels aren't set in stone yet. Right now, they're extremely red, extremely blue, and extremely green.

![](http://www.judoburrito.com/SJNotificationViewController/error.png)

![](http://www.judoburrito.com/SJNotificationViewController/message.png)

![](http://www.judoburrito.com/SJNotificationViewController/success.png)

## Notification Position ##

There is also a property called `notificationPosition` to control whether your notification should appear at the top or at the bottom of its parent view. Set it to `SJNotificationPositionTop` or `SJNotificationPositionBottom` (default) accordingly.

    [notificationController setNotificationPosition:SJNotificationPositionTop];

## Notification Duration ##

By default, a notification stays on screen until you tap it. To automatically hide it after a given delay, just set the property `notificationDuration`. There are a few predefined values for it:

* `SJNotificationDurationStay`, which is the default, keeps the notification on screen until the user taps it.
* `SJNofificationDurationShort` sets it to 1.5 seconds,
* `SJNotificationDurationMedium` sets it to 3 seconds,
* `SJNotificationDurationLong` sets it to 5 seconds
* and finally, `SJNotificationDurationAlmostForever` sets it to 10 seconds.

Instead of giving these typedef'd values, you can also just give the amount of milliseconds as an integer. Examples:

* `[notificationController setNotificationDuration:SJNotificationDurationMedium];` or
* `[notificationController setNotificationDuration:7000];`

## Background and Text Color

You can set the background color as well as text color like this:

* `[notificationController setBackgroundColor:[UIColor brownColor]];` and
* `[notificationController setTextColor:[UIColor yellowColor]];`

## Tapping on a Notification ##

By default, tapping on a notification just hides it, but you can define your own target/selector pair to be called when the notification is tapped with `[notificationController setTapTarget:self action:@selector(doSomething)]`.

## Spinner ##

By default, a notification doesn't have a spinner, but you can give it one by calling `[notificationController setShowSpinner:YES]`. Doing so will shrink the notification's label to fit the spinner.

![](http://www.judoburrito.com/SJNotificationViewController/spinner.png)

## More In-Depth Customisations ##

If you want to get into the .m file, you can change the colours that correspond to the different notification levels, the durations of the various animations, and the opacity of the notification's background.

