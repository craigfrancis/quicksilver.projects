//
//  ProjectsAction.m
//  Projects
//
//  Created by Craig Francis on 22/08/2012.
//

#import "ProjectsAction.h"

@implementation QSProjectsActionProvider

- (QSObject *)performActionOnObject:(QSObject *)dObject{

	NSURL *projectUrl = [dObject objectForMeta:@"url"];
	NSMutableString *projectName = [dObject objectForMeta:@"name"];
	NSMutableString *folderName;
	NSMutableString *projectPath;
	NSString *selectedFolder = @"";
	
	projectPath = [NSMutableString stringWithString:[projectUrl path]];
		
	if ([[dObject objectForMeta:@"type"] isEqualToString: @"project"]) {
		
		// If we are looking at a project (first level), then try to
		// open the "app" or "public" sub-folder if available.
		
		NSArray *items = [[NSFileManager defaultManager]
						  contentsOfDirectoryAtURL:projectUrl
						  includingPropertiesForKeys:[NSArray array]
						  options:0
						  error:NULL];
		
		for (NSURL *url in items) {
			if (CFURLHasDirectoryPath((CFURLRef)url)) {
				
				folderName = [NSMutableString stringWithString: [url lastPathComponent]];
				
				if ([folderName isEqualToString: @"app"]) {
				
					selectedFolder = @"app";
				
				} else if ([folderName isEqualToString: @"public"] && ![selectedFolder isEqualToString: @"app"]) {
				
					selectedFolder = @"public";
				
				}
				
			}
		}

	}

	if (![selectedFolder isEqualToString: @""]) {
		[projectPath appendString:@"/"];
		[projectPath appendString:selectedFolder];
		[projectPath appendString:@"/"];
	} else {
		selectedFolder = [projectUrl lastPathComponent];
	}

	// NSLog(@"Name: %@", projectName);
	// NSLog(@"Folder: %@", selectedFolder);
	// NSLog(@"Path: %@", projectPath);
	// NSLog(@"Parent: %@", [dObject objectForMeta:@"type"]);

	if (true) {
		
		[[NSWorkspace sharedWorkspace] openFile:projectPath withApplication:@"TextMate"];

	} else { // TextMate 1
		
		NSMutableString *tempFilePath;
		NSString *tempDirPath;
		NSMutableString *tempXml;

		tempXml = [NSMutableString stringWithString: @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
		[tempXml appendString: @"<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"];
		[tempXml appendString: @"<plist version=\"1.0\">"];
		[tempXml appendString: @"<dict>"];
		[tempXml appendString: @"	<key>documents</key>"];
		[tempXml appendString: @"	<array>"];
		[tempXml appendString: @"		<dict>"];
		[tempXml appendString: @"			<key>expanded</key>"];
		[tempXml appendString: @"			<true/>"];
		[tempXml appendString: @"			<key>name</key>"];
		[tempXml appendString: @"			<string>"];
		[tempXml appendString: projectName];

		if (![projectName isEqualToString:selectedFolder]) {
			[tempXml appendString: @" ["];
			[tempXml appendString: selectedFolder];
			[tempXml appendString: @"]"];
		}

		[tempXml appendString: @"</string>"];
		[tempXml appendString: @"			<key>regexFolderFilter</key>"];
		[tempXml appendString: @"			<string>!.*/(\\.[^/]*|CVS|_darcs|_MTN|\\{arch\\}|blib|.*~\\.nib|.*\\.(framework|app|pbproj|pbxproj|xcode(proj)?|bundle))$</string>"];
		[tempXml appendString: @"			<key>sourceDirectory</key>"];
		[tempXml appendString: @"			<string>"];
		[tempXml appendString: projectPath];
		[tempXml appendString: @"</string>"];
		[tempXml appendString: @"		</dict>"];
		[tempXml appendString: @"	</array>"];
		[tempXml appendString: @"	<key>fileHierarchyDrawerWidth</key>"];
		[tempXml appendString: @"	<integer>250</integer>"];
		[tempXml appendString: @"	<key>showFileHierarchyDrawer</key>"];
		[tempXml appendString: @"	<true/>"];
		[tempXml appendString: @"	<key>windowFrame</key>"];
		[tempXml appendString: @"	<string>{{446, 112}, {1208, 651}}</string>"];
		[tempXml appendString: @"</dict>"];
		[tempXml appendString: @"</plist>"];
		
		tempDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"QuickSilverProjects"];

		tempFilePath = [NSMutableString stringWithString:tempDirPath];
		[tempFilePath appendString: @"/"];
		[tempFilePath appendString:projectName];
		
		if (![projectName isEqualToString:selectedFolder]) {
			[tempFilePath appendString: @"."];
			[tempFilePath appendString:selectedFolder];
		}

		[tempFilePath appendString: @".tmproj"];
		
		[[NSFileManager defaultManager] createDirectoryAtPath:tempDirPath withIntermediateDirectories:true attributes:nil error:nil];
		[[NSFileManager defaultManager] createFileAtPath:tempFilePath contents:[tempXml dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];

		[[NSWorkspace sharedWorkspace] openFile:tempFilePath withApplication:@"TextMate"];

		// NSLog(@"Temp: %@", tempFilePath);
		
	}

	return nil;
	
}

@end
