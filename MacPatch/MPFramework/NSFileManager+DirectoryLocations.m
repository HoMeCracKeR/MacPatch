//
//  NSFileManager+DirectoryLocations.m
//
//  Created by Matt Gallagher on 06 May 2010
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "NSFileManager+DirectoryLocations.h"

#undef  ql_component
#define ql_component lcl_cMain

enum
{
	DirectoryLocationErrorNoPathFound,
	DirectoryLocationErrorFileExistsAtLocation
};

NSString * const DirectoryLocationDomain = @"DirectoryLocationDomain";

@implementation NSFileManager (DirectoryLocations)

//
// findOrCreateDirectory:inDomain:appendPathComponent:error:
//
// Method to tie together the steps of:
//	1) Locate a standard directory by search path and domain mask
//  2) Select the first path in the results
//	3) Append a subdirectory to that path
//	4) Create the directory and intermediate directories if needed
//	5) Handle errors by emitting a proper NSError object
//
// Parameters:
//    searchPathDirectory - the search path passed to NSSearchPathForDirectoriesInDomains
//    domainMask - the domain mask passed to NSSearchPathForDirectoriesInDomains
//    appendComponent - the subdirectory appended
//    errorOut - any error from file operations
//
// returns the path to the directory (if path found and exists), nil otherwise
//
- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut
{
    return [self findOrCreateDirectory:searchPathDirectory
                              inDomain:domainMask
                   appendPathComponent:appendComponent directoryAttributes:nil
                                 error:errorOut];
}

// MacPatch Addition
// Extended origional to include directory create attributes
- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                directoryAttributes:(NSDictionary *)attributes
                              error:(NSError **)errorOut
{
    NSFileManager *fm = [NSFileManager defaultManager];
	//
	// Search for the path
	//
	NSArray* paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory,domainMask,YES);
	if ([paths count] == 0)
	{
		if (errorOut)
		{
			NSDictionary *userInfo =
            [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedStringFromTable(@"No path found for directory in domain.",@"Errors",nil),
             NSLocalizedDescriptionKey,[NSNumber numberWithInteger:searchPathDirectory],@"NSSearchPathDirectory",[NSNumber numberWithInteger:domainMask],@"NSSearchPathDomainMask",nil];
			*errorOut = [NSError errorWithDomain:DirectoryLocationDomain code:DirectoryLocationErrorNoPathFound userInfo:userInfo];
		}
		return nil;
	}

	//
	// Normally only need the first path returned
	//
	NSString *resolvedPath = [paths objectAtIndex:0];

	//
	// Append the extra path component
	//
	if (appendComponent)
	{
		resolvedPath = [resolvedPath stringByAppendingPathComponent:appendComponent];
	}

    if (attributes) {
        NSError *fErr = nil;
        // Is the App Support Dir Contains permissions to be set
        // Verify them, if they dont match. Delete the dir and let it recreate
        // with the correct ones. Or change permissions :-)
        /*
         if ([fm fileExistsAtPath:resolvedPath]) {
         if (![self isDirectoryPermissionsEqual:resolvedPath permissions:[NSNumber numberWithShort:0777]]) {
         if (![resolvedPath isEqualToString:@"/"]) {
         [NSTask launchedTaskWithLaunchPath:@"/bin/rm" arguments:[NSArray arrayWithObject:@"-r",resolvedPath, nil]];
         }
         }
         }
         */
        // Change all items in App Support Dir to the required permissions
        if ([fm fileExistsAtPath:resolvedPath]) {
            if (![self isDirectoryPermissionsEqual:resolvedPath permissions:[attributes valueForKey:NSFilePosixPermissions]])
            {
                [fm setAttributes:attributes ofItemAtPath:resolvedPath error:&fErr];
                if (fErr) {
                    qlerror(@"Error, %@",fErr.localizedDescription);
                }

                NSArray *contents = [fm contentsOfDirectoryAtPath:resolvedPath error:NULL];
                NSString* fullPath = nil;
                for (NSString *node in contents)
                {
                    fullPath = [NSString stringWithFormat:@"%@%@",resolvedPath,node];
                    [fm setAttributes:attributes ofItemAtPath:fullPath error:nil];
                }
            }
        }
    }

	//
	// Create the path if it doesn't exist
	//
	NSError *error = nil;
	BOOL success = [self createDirectoryAtPath:resolvedPath
                   withIntermediateDirectories:YES
                                    attributes:attributes
                                         error:&error];
	if (!success)
	{
		if (errorOut)
		{
			*errorOut = error;
		}
		return nil;
	}

	//
	// If we've made it this far, we have a success
	//
	if (errorOut)
	{
		*errorOut = nil;
	}
	return resolvedPath;
}

//
// applicationSupportDirectory
//
// Returns the path to the applicationSupportDirectory (creating it if it doesn't
// exist).
//
- (NSString *)applicationSupportDirectory
{
	return [self applicationSupportDirectoryForDomain:NSUserDomainMask];
}

- (NSString *)applicationSupportDirectoryForDomain:(NSSearchPathDomainMask)aDomainMask
{
	return [self applicationSupportDirectoryForDomain:aDomainMask directoryAttributes:nil];
}

// MacPatch Addition
// Extended origional to include directory create attributes
- (NSString *)applicationSupportDirectoryForDomain:(NSSearchPathDomainMask)aDomainMask directoryAttributes:(NSDictionary *)attributes
{
    NSString *executableName;
	if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"]) {
		executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
	} else if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutablePath"]) {
		executableName = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutablePath"] lastPathComponent];
	} else {
		executableName = @"NA";
	}

    NSLog(@"attributes: %@",attributes);

	NSError *error = nil;
    NSString *result;
	result = [self findOrCreateDirectory:NSApplicationSupportDirectory inDomain:aDomainMask appendPathComponent:executableName directoryAttributes:attributes error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
	if (!result)
	{
		NSLog(@"Unable to find or create application support directory:\n%@", error);
	}
	return result;
}

// MacPatch Addition
- (BOOL)isDirectoryPermissionsEqual:(NSString *)path permissions:(NSNumber *)perms
{
    BOOL result = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fm attributesOfItemAtPath:path error:NULL];
    NSNumber *curPosixPermissions = [fileAttributes valueForKey:NSFilePosixPermissions];
    if ([perms isEqualToNumber:curPosixPermissions]) {
        result = YES;
    }
    return result;
}

@end
