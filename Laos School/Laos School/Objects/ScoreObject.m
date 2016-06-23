//
//  ScoreObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreObject.h"
#import "LocalizeHelper.h"

/*
 @property (nonatomic, strong) NSString *scoreID;
 @property (nonatomic, strong) NSString *score;
 @property (nonatomic, strong) NSString *subject;
 @property (nonatomic, strong) NSString *dateTime;
 @property (nonatomic, assign) SCORE_TYPE scoreType;
 @property (nonatomic, strong) NSString *month;
 @property (nonatomic, assign) NSInteger weight;
 @property (nonatomic, strong) NSString *teacherName;
 @property (nonatomic, strong) NSString *comment;
 @property (nonatomic, strong) NSString *termID;
 @property (nonatomic, strong) NSString *term;
 */
@implementation ScoreObject

- (id)init {
    self = [super init];
    if (self) {
        self.scoreID = @"";
        self.score = @"";
        self.subjectID = @"";
        self.subject = @"";
        self.dateTime = @"";
        self.examID = @"";
        self.scoreName = @"";
        self.scoreDisplayName = @"";
        self.scoreType = ScoreType_Normal;
        self.month = 0;
        self.year = 0;
        self.weight = 1;
        
        self.teacherName = @"";
        self.comment = @"";
        self.termID = @"";
        self.term = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.scoreID forKey:@"scoreID"];
    [encoder encodeObject:self.score forKey:@"score"];
    [encoder encodeObject:self.subjectID forKey:@"subjectID"];
    [encoder encodeObject:self.subject forKey:@"subject"];
    [encoder encodeObject:self.dateTime forKey:@"dateTime"];
    [encoder encodeObject:self.examID forKey:@"examID"];
    [encoder encodeObject:self.scoreName forKey:@"scoreName"];
    [encoder encodeObject:self.scoreDisplayName forKey:@"scoreDisplayName"];
    [encoder encodeInteger:self.scoreType forKey:@"scoreType"];
    [encoder encodeInteger:self.month forKey:@"month"];
    [encoder encodeInteger:self.year forKey:@"year"];
    [encoder encodeInteger:self.weight forKey:@"weight"];
    
    [encoder encodeObject:self.teacherName forKey:@"teacherName"];
    [encoder encodeObject:self.comment forKey:@"comment"];
    [encoder encodeObject:self.termID forKey:@"termID"];
    [encoder encodeObject:self.term forKey:@"term"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
        self.scoreID = [decoder decodeObjectForKey:@"scoreID"];
        self.score = [decoder decodeObjectForKey:@"score"];
        self.subjectID = [decoder decodeObjectForKey:@"subjectID"];
        self.subject = [decoder decodeObjectForKey:@"subject"];
        self.dateTime = [decoder decodeObjectForKey:@"dateTime"];
        self.examID = [decoder decodeObjectForKey:@"examID"];
        self.scoreName = [decoder decodeObjectForKey:@"scoreName"];
        self.scoreDisplayName = [decoder decodeObjectForKey:@"scoreDisplayName"];
        self.scoreType = (SCORE_TYPE)[decoder decodeIntegerForKey:@"scoreType"];
        self.month = (SCORE_TYPE)[decoder decodeIntegerForKey:@"month"];
        self.year = (SCORE_TYPE)[decoder decodeIntegerForKey:@"year"];
        self.weight = [decoder decodeIntegerForKey:@"weight"];
        
        self.teacherName = [decoder decodeObjectForKey:@"teacherName"];
        self.comment = [decoder decodeObjectForKey:@"comment"];        
        self.termID = [decoder decodeObjectForKey:@"termID"];
        self.term = [decoder decodeObjectForKey:@"term"];
    }
    
    return self;
}

- (NSString *)scoreDisplayName {
    NSString *res = @"";
    
    if ([_scoreDisplayName isEqualToString:@"Sep"]) {
        res = LocalizedString(@"Sep");
        
    } else if ([_scoreDisplayName isEqualToString:@"Oct"]) {
        res = LocalizedString(@"Oct");
        
    } else if ([_scoreDisplayName isEqualToString:@"Nov"]) {
        res = LocalizedString(@"Nov");
        
    } else if ([_scoreDisplayName isEqualToString:@"Dec"]) {
        res = LocalizedString(@"Dec");
        
    } else if ([_scoreDisplayName isEqualToString:@"Feb"]) {
        res = LocalizedString(@"Feb");
        
    } else if ([_scoreDisplayName isEqualToString:@"Mar"]) {
        res = LocalizedString(@"Mar");
        
    } else if ([_scoreDisplayName isEqualToString:@"Apr"]) {
        res = LocalizedString(@"Apr");
        
    } else if ([_scoreDisplayName isEqualToString:@"May"]) {
        res = LocalizedString(@"May");
        
    } else if ([_scoreDisplayName isEqualToString:@"Aver4Months1"]) {
        res = LocalizedString(@"Ave_m1");
        
    } else if ([_scoreDisplayName isEqualToString:@"TermExam1"]) {
        res = LocalizedString(@"Test term I");
        
    } else if ([_scoreDisplayName isEqualToString:@"AverageTerm1"]) {
        res = LocalizedString(@"Ave term I");
        
    } else if ([_scoreDisplayName isEqualToString:@"Aver4Months2"]) {
        res = LocalizedString(@"Ave_m2");
        
    } else if ([_scoreDisplayName isEqualToString:@"TermExam2"]) {
        res = LocalizedString(@"Test term II");
        
    } else if ([_scoreDisplayName isEqualToString:@"AverageTerm2"]) {
        res = LocalizedString(@"Ave term II");
        
    } else if ([_scoreDisplayName isEqualToString:@"Overall"]) {
        res = LocalizedString(@"Ave year");
        
    } else if ([_scoreDisplayName isEqualToString:@"Retest"]) {
        res = LocalizedString(@"Retest");
        
    } else if ([_scoreDisplayName isEqualToString:@"Graduation"]) {
        res = LocalizedString(@"Test grad");
        
    }
    
    return res;
}
@end