
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

extern NSString * TPAACAudioConverterErrorDomain;

enum {
    TPAACAudioConverterFileError,
    TPAACAudioConverterFormatError,
    TPAACAudioConverterUnrecoverableInterruptionError,
    TPAACAudioConverterInitialisationError
};

@protocol TPAACAudioConverterDelegate;
@protocol TPAACAudioConverterDataSource;

@interface TPAACAudioConverter : NSObject

+ (BOOL)AACConverterAvailable;

- (id)initWithDelegate:(id<TPAACAudioConverterDelegate>)delegate source:(NSString*)sourcePath destination:(NSString*)destinationPath;
- (id)initWithDelegate:(id<TPAACAudioConverterDelegate>)delegate dataSource:(id<TPAACAudioConverterDataSource>)dataSource audioFormat:(AudioStreamBasicDescription)audioFormat destination:(NSString*)destinationPath;
- (void)start;
- (void)cancel;

- (void)interrupt;
- (void)resume;

@property (nonatomic, readonly, retain) NSString *source;
@property (nonatomic, readonly, retain) NSString *destination;
@property (nonatomic, readonly) AudioStreamBasicDescription audioFormat;
@end


@protocol TPAACAudioConverterDelegate <NSObject>
- (void)AACAudioConverterDidFinishConversion:(TPAACAudioConverter*)converter;
- (void)AACAudioConverter:(TPAACAudioConverter*)converter didFailWithError:(NSError*)error;
@optional
- (void)AACAudioConverter:(TPAACAudioConverter*)converter didMakeProgress:(float)progress;
@end

@protocol TPAACAudioConverterDataSource <NSObject>
- (void)AACAudioConverter:(TPAACAudioConverter*)converter nextBytes:(char*)bytes length:(NSUInteger*)length;
@optional
- (void)AACAudioConverter:(TPAACAudioConverter *)converter seekToPosition:(NSUInteger)position;
@end