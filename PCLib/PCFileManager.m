/*
   GNUstep ProjectCenter - http://www.gnustep.org

   Copyright (C) 2001 Free Software Foundation

   Author: Philippe C.D. Robert <probert@siggraph.org>

   This file is part of GNUstep.

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.

   $Id$
*/

#import "PCFileManager.h"
#import "PCDefines.h"
#import "PCProject.h"
#import "PCServer.h"
#import "FileCreator.h"

#import "PCFileManager+UInterface.h"

#if defined(GNUSTEP)
#import <AppKit/IMLoading.h>
#endif

@implementation PCFileManager

//==============================================================================
// ==== Class methods
//==============================================================================

static PCFileManager *_mgr = nil;

+ (PCFileManager *)fileManager
{
  if (!_mgr) {
    _mgr = [[PCFileManager alloc] init];
  }
  return _mgr;
}

//==============================================================================
// ==== Init and free
//==============================================================================

- (id)init
{
    if ((self = [super init])) 
    {
       	creators = [[NSMutableDictionary alloc] init];
       	typeDescr = [[NSMutableDictionary alloc] init];

	[self _initUI];
    }
    return self;
}

- (void)dealloc
{
  RELEASE(creators);
  RELEASE(newFileWindow);
  RELEASE(typeDescr);
  
  [super dealloc];
}

- (void)awakeFromNib
{
  [fileTypePopup removeAllItems];
}

// ===========================================================================
// ==== Delegate
// ===========================================================================

- (id)delegate
{
  return delegate;
}

- (void)setDelegate:(id)aDelegate
{
  delegate = aDelegate;
}

// ===========================================================================
// ==== File stuff
// ===========================================================================

- (void)showAddFileWindow
{
  NSOpenPanel *openPanel;
  int retval;
  
  PCProject *project = nil;
  NSString *key = nil;
  NSString *title = nil;
  NSArray *types = nil;

  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

  if (delegate && 
      [delegate respondsToSelector:@selector(fileManagerWillAddFiles:)]) 
  {

    if (!(project = [delegate fileManagerWillAddFiles:self])) 
    {
      return;
    }
  }

  key = [project selectedRootCategory];

  title = [[[project rootCategories] allKeysForObject:key] objectAtIndex:0];
  title = [NSString stringWithFormat:@"Add to %@...",title];

  types = [project fileExtensionsForCategory:key];

  openPanel = [NSOpenPanel openPanel];
  [openPanel setAllowsMultipleSelection:YES];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanChooseFiles:YES];
  [openPanel setTitle:title];

  retval = [openPanel runModalForDirectory:[ud objectForKey:@"LastOpenDirectory"] file:nil types:types];

  if (retval == NSOKButton) 
  {
    NSEnumerator *enumerator;
    NSString *file;
    
    [ud setObject:[openPanel directory] forKey:@"LastOpenDirectory"];
    
    enumerator = [[openPanel filenames] objectEnumerator];
    while (file = [enumerator nextObject]) {
      NSString *otherKey;
      NSString *ext;
      BOOL ret = NO;
      NSString *fn;
      NSString *fileName;
      NSString *pth;

      if ([delegate fileManager:self shouldAddFile:file forKey:key]) 
      {
        NSFileManager *fm = [NSFileManager defaultManager];

	fileName = [file lastPathComponent];
	pth = [[project projectPath] stringByAppendingPathComponent:fileName];
	
	if (![key isEqualToString:PCLibraries]) 
        {
	  if (![fm fileExistsAtPath:pth]) 
          {
	    [fm copyPath:file toPath:pth handler:nil];
	  }
	}
	[project addFile:pth forKey:key];
      }

      if ([key isEqualToString:PCClasses]) 
      {
	otherKey = PCHeaders;
	ext = [NSString stringWithString:@"h"];

	fn = [file stringByDeletingPathExtension];
	fn = [fn stringByAppendingPathExtension:ext];

	if ([[NSFileManager defaultManager] fileExistsAtPath:fn]) 
        {
	  ret = NSRunAlertPanel(@"Adding Header?",
                                @"Should %@ be added to project %@ as well?",
                                @"Yes",@"No",nil,fn,[project projectName]);
	}
      }
      else if ([key isEqualToString:PCHeaders]) 
      {
	otherKey = PCClasses;
	ext = [NSString stringWithString:@"m"];

	fn = [file stringByDeletingPathExtension];
	fn = [fn stringByAppendingPathExtension:ext];

	if ([[NSFileManager defaultManager] fileExistsAtPath:fn]) 
        {
	  ret = NSRunAlertPanel(@"Adding Class?",
                                @"Should %@ be added to project %@ as well?",
                                @"Yes",@"No",nil,fn,[project projectName]);
	}
      }

      if (ret) 
      {
	if ([delegate fileManager:self shouldAddFile:fn forKey:otherKey]) 
        {
	  NSString *pp = [project projectPath];

	  fileName = [fn lastPathComponent];
	  pth = [pp stringByAppendingPathComponent:fileName];

          /* Only copy the file if it isn't already there */
	  if ([pth isEqual: fn] == NO)
	    [[NSFileManager defaultManager] copyPath:fn toPath:pth handler:nil];

	  [project addFile:pth forKey:otherKey];
	}
      }
    }
  }
}

- (void)showNewFileWindow
{
  [self popupChanged:fileTypePopup];

  [newFileWindow center];
  [newFileWindow makeKeyAndOrderFront:self];
}

- (void)buttonsPressed:(id)sender
{
  switch ([[sender selectedCell] tag]) 
  {
  case 0:
    break;
  case 1:
    [self createFile];
    break;
  }
  [newFileWindow orderOut:self];
  [newFileName setStringValue:@""];
}

- (void)popupChanged:(id)sender
{
    NSString *k = [sender titleOfSelectedItem];

    if( k ) 
    {
#ifdef GNUSTEP_BASE_VERSION
	[descrView setText:[typeDescr objectForKey:k]];
#else
	[descrView setString:[typeDescr objectForKey:k]];
#endif
    }
}

- (void)createFile
{
  NSString *path = nil;
  NSString *fileName = [newFileName stringValue];
  NSString *fileType = [fileTypePopup titleOfSelectedItem];
  NSString *key = [[creators objectForKey:fileType] objectForKey:@"ProjectKey"];
  
  if (delegate) 
  {
    path = [delegate fileManager:self willCreateFile:fileName withKey:key];
  }

#ifdef DEBUG  
  NSLog(@"<%@ %x>: creating file at %@",[self class],self,path);
#endif //DEBUG

  // Create file
  if (path) 
  {
    NSDictionary *newFiles;
    id<FileCreator> creator = [[creators objectForKey:fileType] objectForKey:@"Creator"];
    PCProject *p = [delegate activeProject];

    if (!creator) 
    {
      NSRunAlertPanel(@"Attention!",
                      @"Could not create %@. The creator is missing!",
                      @"OK",nil,nil,fileName);
      return;
    }
    
    // Do it finally...
    newFiles = [creator createFileOfType:fileType path:path project:p];
    if (delegate 
        && [delegate respondsToSelector:@selector(fileManager:didCreateFile:withKey:)]) 
    {
      NSEnumerator *enumerator;
      NSString *aFile;
      
      enumerator = [[newFiles allKeys] objectEnumerator]; // Key: name of file
      while (aFile = [enumerator nextObject]) 
      {
	NSString *theType = [newFiles objectForKey:aFile];
	NSString *theKey = [[creators objectForKey:theType] objectForKey:@"ProjectKey"];
	
	[delegate fileManager:self didCreateFile:aFile withKey:theKey];
      }
    }
  }
}

- (void)registerCreatorsWithObjectsAndKeys:(NSDictionary *)dict
{
  NSEnumerator *enumerator = [dict keyEnumerator];
  id type;

#ifdef DEBUG  
  NSLog(@"<%@ %x>: Registering creators...",[self class],self);
#endif //DEBUG

  while (type = [enumerator nextObject]) 
  {
    NSDictionary *cd = [dict objectForKey:type];
    id creator = [cd objectForKey:@"Creator"];
    
    if (![creator conformsToProtocol:@protocol(FileCreator)]) 
    {
      [NSException raise:@"FileManagerGenericException" 
            format:@"The target does not conform to the FileCreator protocol!"];
      return;
    }
    
    if ([creators objectForKey:type]) 
    {
      [NSException raise:@"FileManagerGenericException" 
                 format:@"There is alreay a creator registered for this type!"];
      return;
    }
    
    // Register the creator!
    [creators setObject:[dict objectForKey:type] forKey:type];
    [fileTypePopup addItemWithTitle:type];

    if( [cd objectForKey:@"TypeDescription"] )
    {
        [typeDescr setObject:[cd objectForKey:@"TypeDescription"] forKey:type];
    }
  }
}

@end



