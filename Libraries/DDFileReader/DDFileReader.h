//
//  DDFileReader.h - Reads a text file line by line
//
//  Author: Dave Delong <http://stackoverflow.com/users/115730/dave-delong>
//  Taken from Stack Overflow: http://stackoverflow.com/questions/3707427/how-to-read-data-from-nsfilehandle-line-by-line#3711079 
//

@interface DDFileReader : NSObject {
    NSString * filePath;
    
    NSFileHandle * fileHandle;
    unsigned long long currentOffset;
    unsigned long long totalFileLength;
    
    NSString * lineDelimiter;
    NSUInteger chunkSize;
}

@property (nonatomic, copy) NSString * lineDelimiter;
@property (nonatomic) NSUInteger chunkSize;

- (id) initWithFilePath:(NSString *)aPath;

- (NSString *) readLine;
- (NSString *) readTrimmedLine;

#if NS_BLOCKS_AVAILABLE
- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL *))block;
#endif

@end
