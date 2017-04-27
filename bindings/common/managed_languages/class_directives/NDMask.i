// Todo: add correct typemap as they might be useful in future.
%ignore_function CNTK::NDMask::DataBuffer;
%rename (GetMaskedCount) CNTK::NDMask::MaskedCount;
%rename (GetDevice) CNTK::NDMask::Device;
%rename (GetShape) CNTK::NDMask::Shape;
%rename (_InvalidateSection) CNTK::NDMask::InvalidateSection;
%rename (_MarkSequenceBegin) CNTK::NDMask::MarkSequenceBegin;
%rename (_InvalidateSection) CNTK::NDMask::InvalidateSection;

