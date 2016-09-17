//
//  Constants.h
//  FakeVoat
//
//  Created by Stas on 07.07.15.
//  Copyright (c) 2015 distvi. All rights reserved.
//

#ifndef FakeVoat_Constants_h
#define FakeVoat_Constants_h

// utils
#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define rgbaColor(r,g,b, a)     [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define rgbColor(r,g,b)         rgbaColor(r,g,b,1)
#define UIColorFromHEX(rgbValue) \
        [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                        green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                         blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                        alpha:1.0]

#define kPlaceholderBlue    rgbColor(169,230,251)
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

// notifications

#define kNotificationHideTicketController   @"kNotificationHideTicketController"
#define kNotificationHidePopup   @"kNotificationHidePopup"
#define kNotificationShowPinPopup   @"kNotificationShowPinPopup"

// Fonts

#define kFontUserScore  @"CoreSansGRounded-Bold"



#endif
