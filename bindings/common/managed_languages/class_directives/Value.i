%apply int INPUT[]  { int *colStarts }
%apply int INPUT[]  { int *rowIndices }
%apply float INPUT[]  { float *nonZeroValues }
%apply double INPUT[]  { double *nonZeroValues }

%rename (GetDevice) CNTK::Value::Device;
%rename (GetShape) CNTK::Value::Shape;
%rename (_IsSparse) CNTK::Value::IsSparse;
%rename (_IsReadOnly) CNTK::Value::IsReadOnly;
%rename (_MaskedCount) CNTK::Value::MaskedCount;

%include "../../CNTKValueExtend.i"

