EasyPD

Copyright (c) 2015-present justKD.
Licensed under the MIT license.

EasyPD is a high level abstraction to streamline the use of LIBPD in iOS projects.
It is meant to help new users avoid copy-pasting and troubleshooting boilerplate code.

TODO: 
-	EasyPD is subclassed from UIControl. Will add UIEvent for libpd listeners.
-	Add option to initialize for recording.


Instructions

ADD LIBPD:

- Copy the EasyPD folder (includes EasyPD class files and LIBPD folder) to your project folder.

- Add the LIBPD Xcode project to your Xcode project.
	- Use “Add files to…”
	- The path is <EasyPD/libpd/libpd.xcodeproj>

- Add the EasyPD class files to your Xcode project.

- Go to “Build Phases” and add ‘libpd-ios’ to ‘Target Dependencies’.

- Also in “Build Phases” add ‘libpd-ios.a’ to ‘Link Binary With Libraries’.
	- ‘libpd-ios.a’ may show up red: do not worry about it.

- Now go to “Build Settings” and search for “User Header Search Paths”
	- Double click on the field to add a search path
	- Add the path “easypd/libpd/..” (without quotes) and set it to “recursive”


** All of the paths above assume you add EasyPD to the root project folder. Adjust the paths accordingly in you place it deeper in the folder structure.



Set up EasyPD:

- Use “Add files to…” and add your PD file.
	- Notes on creating a PD file to use with LIBPD are below.

- Import “EasyPD.h” to your .m file

- Add a property for EasyPD
	- e.g.- @property (nonatomic, strong) EasyPD *pd;

- Finish set up in an appropriate place, such as the viewDidLoad: method of a view controller
	- Example set up code:

		self.pd = [[EasyPD alloc] init];
   		NSString *patchString = [NSString stringWithFormat:@"EasyPD_Demo.pd"];
    		[self.pd initializeWithPatch:patchString];


Use EasyPD:

- Your PD patch should have typical PD receive objects set up to receive data from your iOS project
	- For example, the frequency inlet for an [osc~] object might be connected to an [r freq] object.
    - The string for that receiver would simply be @"freq"

- In order to send data to PD, call methods as follows:

	- Example method calls based on the above example set up code:
        - These calls are identical to the normal LIBPD ones. The only difference is that all of the PDBase set up code is wrapped into its own Cocoa Touch class.
	
		[self.pd sendBangToReceiver:@"click"];
		[self.pd sendFloat:sender.value toReceiver:@"freq"];
 		[self.pd sendFloat:1 toReceiver:@"start"];
		[self.pd sendSymbol:@“doit 1“ toReceiver:@“route”];

	- EasyPD defaults to audio on, but you can manually toggle audio processing with:

		[self.pd setActive:YES];
		[self.pd setActive:NO];


Use EasyPD with Swift:

After importing libpd and EasyPD into your project, let xcode automatically create a bridging header.

In the new header file, add the statement:
    #import "EasyPD.h"

Now the EasyPD class can be used in swift:
     guard let pd = EasyPD(patch: "EasyPD_Demo.pd") else { return }

     pd.send(1, toReceiver: "start")
     pd.sendBang(toReceiver: "click")

