//
// QR Code Generator - generates UIImage from NSString
//
// Copyright (C) 2012 http://moqod.com Andrew Kopanev <andrew@moqod.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all 
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
//

#import "QRCodeGenerator.h"

@implementation QRCodeGenerator

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size
{
    NSString *text = [string stringByReplacingOccurrencesOfString:@"\n" withString:@"/"];
    text = [text stringByReplacingOccurrencesOfString:@"\t" withString:@"/"];
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@"/"];
    
    return [self qrImageForString:string imageSize:size text:text];
}

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size text:(NSString *)text
{
	if (![string length]) {
		return nil;
    }
    
    UIImage *image = [self.class createCodeImageWithString:string];
	
	// create context
    CGFloat scale = [UIScreen mainScreen].scale;
    size = size * scale;
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
	
	CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
	CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
	
    UIGraphicsPushContext(ctx);
    [image drawInRect:CGRectMake(25, 25, size-50, size-50)];
    
    //段落格式
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;//水平居中
    /*写文字*/
    //string = @"设置填充文字";
    UIFont  *font = [UIFont boldSystemFontOfSize:11.0*scale];//设置
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyle,NSForegroundColorAttributeName:[UIColor blueColor]};
    [text drawInRect:CGRectMake(0, 5, size, 25*scale) withAttributes:attributes];
    UIGraphicsPopContext();
	
	// get image
	CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
	UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage scale:scale orientation:UIImageOrientationUp];
	
	// some releases
	CGContextRelease(ctx);
	CGImageRelease(qrCGImage);
	
	return qrImage;
}

#pragma mark 生成图片
/**
 *  生成一张普通的二维码
 *
 *  @param data    传入你要生成二维码的数据
 *  @param imageViewWidth    图片的宽度
 */

+ (UIImage *)createCodeImageWithString:(NSString *)imgStr
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 120;
    NSData *strData = [imgStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    //创建二维码滤镜
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setDefaults];
    [qrFilter setValue:strData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    CIImage *qrImage = qrFilter.outputImage;
    //颜色滤镜
//    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
//    [colorFilter setDefaults];
//    [colorFilter setValue:qrImage forKey:kCIInputImageKey];
//    [colorFilter setValue:[CIColor colorWithRed:0 green:0 blue:0] forKey:@"inputColor0"];
//
//    [colorFilter setValue:[CIColor colorWithRed:1 green:1 blue:1] forKey:@"inputColor1"];
//    qrImage = colorFilter.outputImage;
    //返回二维码
    qrImage = [qrImage imageByApplyingTransform:CGAffineTransformMakeScale(width/4, width/4)];
    UIImage *codeImage = [UIImage imageWithCIImage:qrImage];
    return codeImage;
}

@end
