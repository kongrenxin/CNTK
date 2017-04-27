%rename (GetName) CNTK::Axis::Name;
%rename (IsOrderedAxis) CNTK::Axis::IsOrdered;
%rename (AreEqualAxis) CNTK::operator==(const Axis& first, const Axis& second);
%ignore_function CNTK::Axis::DefaultDynamicAxis();
%ignore_function CNTK::Axis::OperandSequenceAxis();
%ignore_function CNTK::Axis::DefaultBatchAxis();
%ignore_function CNTK::Axis::AllStaticAxes();
%ignore_function CNTK::Axis::AllAxes();
%ignore_function CNTK::Axis::DefaultInputVariableDynamicAxes();
%ignore_function CNTK::Axis::UnknownDynamicAxes();

