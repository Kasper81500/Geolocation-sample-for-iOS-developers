#import "NSDate+JSON.h"

@implementation NSDate (JSON)

+ (NSDate *)dateFronJSON:(NSString *)jsonString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    NSString *dateFormat1 = @"yyyy-MM-dd HH:mm:ss"; // 2015-09-02 21:49:51";
    NSString *dateFormat2 = @"yyyy-MM-dd"; //2011-11-11
    NSString *dateFormat3 = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"; // 2015-07-11T06:33:26.023Z
    NSString *dateFormat4 = @"EEE, dd MMM yyyy HH:mm:ss ZZZ"; // Fri, 17 Jul 2015 15:47:28 GMT
    NSString *dateFormat5 = @"yyyy-MM-dd'T'HH:mm:ss"; // 2015-07-30T08:15:49
    
    NSArray *formats = @[dateFormat1,dateFormat2,dateFormat3,dateFormat4,dateFormat5];
    
    for (NSString *df in formats) {
        [dateFormat setDateFormat:df];
        NSDate *date = [dateFormat dateFromString:jsonString];
        
        if (date) {
            return date;
        }
    }
    
    
//    if (jsonString) {
//        NSLog(@"\n\n\n\n\nMissing date format for JSON : %@",jsonString);
//    }
    
    return nil;
}

@end
