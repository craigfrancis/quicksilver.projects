//
//  ProjectsSource.m
//  Projects
//
//  Created by Craig Francis on 22/08/2012.
//

#import "ProjectsSource.h"

@implementation QSProjectsSource

- (BOOL)usesGlobalSettings {return YES;}
- (BOOL)scanInMainThread { return YES;}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry
{
	return NO;
}

- (NSImage *)iconForEntry:(NSDictionary *)dict
{
	return nil;
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry
{

   	QSObject *newObject;
	NSURL *rootUrl = [NSURL fileURLWithPath:@"/Volumes/WebServer/Projects/"];
	NSMutableArray *objects = [NSMutableArray array];
	NSMutableString *projectName;
	
	NSArray *items = [[NSFileManager defaultManager]
					  contentsOfDirectoryAtURL:rootUrl
					  includingPropertiesForKeys:[NSArray array]
					  options:0
					  error:NULL];
	
	for (NSURL *url in items) {
		if (CFURLHasDirectoryPath((CFURLRef)url)) {
 
			projectName = [NSMutableString stringWithString: [url lastPathComponent]];
			
			// Ignore the project "a" (archive), and hidden folders
			
			if (![projectName isEqualToString: @"a"] && ![[projectName substringWithRange: NSMakeRange (0, 1)] isEqualToString: @"."]) {
			
				newObject=[QSObject objectWithName:projectName];
				[newObject setIdentifier:[url absoluteString]];
                [newObject setDetails:[url absoluteString]];
                [newObject setIcon:[QSResourceManager imageNamed:@"com.macromates.textmate"]];
				[newObject setObject:@"Project" forType:QSProjectsType];
				[newObject setObject:@"project" forMeta:@"type"];
				[newObject setObject:url forMeta:@"url"];
				[newObject setObject:projectName forMeta:@"name"];
				[objects addObject:newObject];

			}

		}
	}

	return objects;

}

- (BOOL)objectHasChildren:(QSObject *)object
{
	return YES;
}

- (BOOL)loadChildrenForObject:(QSObject *)object
{

   	QSObject *newObject;
	NSURL *rootUrl = [object objectForMeta:@"url"];
	NSMutableString *projectName = [object objectForMeta:@"name"];
	NSMutableString *folderName;
	NSMutableArray *objects = [NSMutableArray array];

	NSArray *items = [[NSFileManager defaultManager]
					  contentsOfDirectoryAtURL:rootUrl
					  includingPropertiesForKeys:[NSArray array]
					  options:0
					  error:NULL];

	for (NSURL *url in items) {
		if (CFURLHasDirectoryPath((CFURLRef)url)) {
			
			folderName = [NSMutableString stringWithString: [url lastPathComponent]];
			
			// Ignore hidden folders
			
			if (![[folderName substringWithRange: NSMakeRange (0, 1)] isEqualToString: @"."]) {

				newObject=[QSObject objectWithName:folderName];
				[newObject setParentID:[object identifier]];
				[newObject setIdentifier:[url absoluteString]];
                [newObject setDetails:[url absoluteString]];
                [newObject setIcon:[QSResourceManager imageNamed:@"com.macromates.textmate"]];
				[newObject setObject:@"Project Folder" forType:QSProjectsType];
				[newObject setObject:@"folder" forMeta:@"type"];
				[newObject setObject:url forMeta:@"url"];
                [newObject setObject:projectName forMeta:@"name"];
				[objects addObject:newObject];

			}
			
		}
	}
	
	[object setChildren:objects];
	return TRUE;

}





// Object Handler Methods

/*
- (void)setQuickIconForObject:(QSObject *)object
{
	[object setIcon:nil]; // An icon that is either already in memory or easy to load
}

- (BOOL)loadIconForObject:(QSObject *)object
{
	return NO;
	id data=[object objectForType:QSProjectsType];
	[object setIcon:nil];
	return YES;
}
*/
@end
