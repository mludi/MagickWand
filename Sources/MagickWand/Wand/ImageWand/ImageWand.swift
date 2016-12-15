// ImageWand.swift
//
// Copyright (c) 2016 Sergey Minakov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

#if os(Linux)
    import CMagickWandLinux
#else
    import CMagickWandOSX
#endif

public class ImageWand: Wand {
    
    internal var pointer: OpaquePointer
    
    public var isMagickWand: Bool {
        return IsMagickWand(self.pointer).bool
    }
    
    public var imageBytes: [UInt8] {
        var size: Int = 0
        guard let imageBlob = MagickGetImageBlob(self.pointer, &size) else {
            return []
        }
        
        defer {
            MagickRelinquishMemory(imageBlob)
        }
        
        var result = [UInt8](repeating: 0, count: size)
        for i in 0..<size {
            result[i] = imageBlob[i]
        }
        
        return result
    }
    
    public var data: Data {
        let array = self.imageBytes
        return Data(bytes: array)
    }
    
    deinit {
        self.clear()
        self.destroy()
    }
    
    public required init?() {
        guard let pointer = NewMagickWand() else { return nil }
        self.pointer = pointer
    }
    
    public required init(pointer: OpaquePointer) {
        self.pointer = pointer
    }
    
    public convenience init?(color: String) {
        self.init()
        guard let pixel = PixelWand() else { return nil }
        print("color)")
        
        _ = color.withCString { name in
            PixelSetColor(pixel.pointer, name)
        }
//
//        self.background = pixel
        
        var image: OpaquePointer? = NewMagickWand()
        MagickNewImage(image, 800, 800, pixel.pointer)
        var a: Int = 0
        var size = 0
        MagickGetImageBlob(image, &a)
        _ = "*".withCString { format in
            MagickSetFormat(image, format)//MagickSetImageFormat(image, format)
        }
        print("\(image), \(a), \(MagickGetImageWidth(image)), \(MagickGetImageBlob(image, &size))")
        
        
        print("\(CloneMagickWand(image)), \(a), \(MagickGetImageWidth(CloneMagickWand(image))), \(MagickGetImageBlob(CloneMagickWand(image), &size))")
        
        
        
//        MagickConstituteImage(<#T##OpaquePointer!#>, <#T##Int#>, <#T##Int#>, <#T##UnsafePointer<Int8>!#>, <#T##StorageType#>, <#T##UnsafeRawPointer!#>)
    }
    
    public func clear() {
        ClearMagickWand(self.pointer)
    }
    
    public func clone() -> Self? {
        guard let pointer = CloneMagickWand(self.pointer) else { return nil }
        return type(of: self).init(pointer: pointer)
    }
    
    public func destroy() {
        guard MagickWand.isInstantiated else { return }
        DestroyMagickWand(self.pointer)
    }
}
