//
//  MPASUSCatalogs.m
/*
 Copyright (c) 2013, Lawrence Livermore National Security, LLC.
 Produced at the Lawrence Livermore National Laboratory (cf, DISCLAIMER).
 Written by Charles Heizer <heizer1 at llnl.gov>.
 LLNL-CODE-636469 All rights reserved.
 
 This file is part of MacPatch, a program for installing and patching
 software.
 
 MacPatch is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License (as published by the Free
 Software Foundation) version 2, dated June 1991.
 
 MacPatch is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the IMPLIED WARRANTY OF MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the terms and conditions of the GNU General Public
 License for more details.
 
 You should have received a copy of the GNU General Public License along
 with MacPatch; if not, write to the Free Software Foundation, Inc.,
 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#import "MPASUSCatalogs.h"
#import "MPWebServices.h"
#import "MPNetworkUtils.h"
#import "MPSystemInfo.h"

#undef  ql_component
#define ql_component lcl_cMPASUSCatalogs

@implementation MPASUSCatalogs

-(id)init
{
    self = [super init];
	if (self)
    {
        mpNetworkUtils = [[MPNetworkUtils alloc] init];
    }
    return self;
}


#pragma mark -

- (NSString *)readCatalogURL
{
	// This method will read the CatalogURL property from the ASUS plist
	NSString *result = @"EMPTY";
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:ASUS_PLIST_PATH]) {
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:ASUS_PLIST_PATH];
		if ([dict objectForKey:@"CatalogURL"]) {
			result = [NSString stringWithFormat:@"%@",[dict objectForKey:@"CatalogURL"]];
		}
	} else {
		qlerror(@"%@ is missing, can not read value.",ASUS_PLIST_PATH);
	}
	
	return result;
}

- (NSDictionary *)getCatalogURLSFromServer
{
	NSDictionary	*catalogURLDict = NULL;
    NSError *err = nil;
    MPWebServices *mpw = [[MPWebServices alloc] init];
    catalogURLDict = [mpw getCatalogURLSForHostOS:&err];
    if (err) {
		qlerror(@"%@",[err localizedDescription]);
        return nil;
	}
    
	return catalogURLDict;
}


- (BOOL)checkAndSetCatalogURL
{
	BOOL result = FALSE;
	NSDictionary *catDict = [self getCatalogURLSFromServer];
	if (!catDict) {
		qlerror(@"Problem parsing catalog plist data.");
		return result;
	}
    
	NSString *currentCatalogURL = [self readCatalogURL];
	NSMutableArray *catURLS = [[NSMutableArray alloc] init];
	if ([catDict objectForKey:@"CatalogURLS"]) {
		[catURLS addObjectsFromArray:[catDict objectForKey:@"CatalogURLS"]];
    }
	if ([catDict objectForKey:@"ProxyCatalogURLS"]) {
		[catURLS addObjectsFromArray:[catDict objectForKey:@"ProxyCatalogURLS"]];	
    }
	
	NSString *newCatalogURL = NULL;
	if ([catURLS count] > 0 ) {
		for(int i=0;i<[catURLS count];i++) {
			// Check to make sure host is reachable and we get a vaild return code
            if ([mpNetworkUtils isHostURLReachable:[catURLS objectAtIndex:i]]) {
				if ([mpNetworkUtils isURLValid:[catURLS objectAtIndex:i] returnCode:200]) {
					newCatalogURL = [catURLS objectAtIndex:i];
					break;
				} else {
                    qlerror(@"CatalogURL: %@ did not return 200.",[catURLS objectAtIndex:i]);
					continue;
				}
			} else {
                qlerror(@"CatalogURL: %@ is not reachable.",[catURLS objectAtIndex:i]);
				continue;	
			}
		}
		
		if ([currentCatalogURL isEqualToString:newCatalogURL] == FALSE) {
			if ([self writeCatalogURL:newCatalogURL]) {
				result = YES;
			}
		} else {
			result = YES;
		}
	} else {
		// CatalogURL is not defined, use the default Apple Config
		result = YES;
	}

	return result;
}

- (BOOL)writeCatalogURL:(NSString *)aCatalogURL
{
	BOOL result = TRUE;
	NSMutableDictionary *tmpDefaults = [NSMutableDictionary dictionaryWithContentsOfFile:ASUS_PLIST_PATH];
	if (aCatalogURL) {
		[tmpDefaults setObject:aCatalogURL forKey:@"CatalogURL"];
	} else {
		qlerror(@"Unable to set catalog url (%@), using Apple built-in.", aCatalogURL);
		if ([tmpDefaults objectForKey:@"CatalogURL"]) {
			[tmpDefaults removeObjectForKey:@"CatalogURL"];
        }
        return FALSE;
	}
	
	@try
    {
        NSDictionary *osVerInfo = [MPSystemInfo osVersionOctets];
        if ([[osVerInfo objectForKey:@"minor"] intValue] >= 9)
        {
            // For Mac OS X 10.9
            [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/softwareupdate" arguments:[NSArray arrayWithObjects:@"--set-catalog",aCatalogURL,nil]];
        }
        else
        {
            [tmpDefaults writeToFile:ASUS_PLIST_PATH atomically:NO];
        }
	}
	@catch ( NSException *e )
    {
		qlerror(@"Error unable to write new config.");
		result = FALSE;
	}
	
	return result;
}

- (BOOL)disableCatalogURL
{
	// Disabled this, using interceptor now...
	//return [self writeCatalogURL:@"http://127.0.0.1:8088/index.sucatalog"];
	return YES;
}


@end
