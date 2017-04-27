%ignore CNTK::Function::BlockArgumentsMapping;
%rename (GetName) CNTK::Function::Name;
%rename (GetUid) CNTK::Function::Uid;
%rename (GetRootFunction) CNTK::Function::RootFunction;
%rename (GetInputs) CNTK::Function::Inputs;
%rename (GetOutput) CNTK::Function::Output;
%rename (GetOutputs) CNTK::Function::Outputs;
%rename (GetArguments) CNTK::Function::Arguments;
%rename (GetOpName) CNTK::Function::OpName;
%rename (_Clone) CNTK::Function::Clone;
%rename (_FindAllWithName) CNTK::Function::FindAllWithName;
%rename (_IsComposite) CNTK::Function::IsComposite;
%rename (_IsPrimitive) CNTK::Function::IsPrimitive;
%rename (_IsBlock) CNTK::Function::IsBlock;


%ignore CNTK::Function::Load(const std::wstring& filepath, const DeviceDescriptor& computeDevice = DeviceDescriptor::UseDefaultDevice(), const Internal::UDFDeserializerPtr& deserializer);
%ignore CNTK::Function::Load(const char* buffer, size_t length, const DeviceDescriptor& computeDevice = DeviceDescriptor::UseDefaultDevice(), const Internal::UDFDeserializerPtr& deserializer = nullptr);
// Ignore exposing istream to C# for now. Todo: find a good solution to map C# System.IO.Stream to std::istream.
%ignore CNTK::Function::Load(std::istream& inputStream, const DeviceDescriptor& computeDevice= DeviceDescriptor::UseDefaultDevice(), const Internal::UDFDeserializerPtr& deserializer = nullptr);

%extend CNTK::Function {
    static FunctionPtr Load(const std::wstring& filepath, 
                            const CNTK::DeviceDescriptor& computeDevice = CNTK::DeviceDescriptor::UseDefaultDevice()) 
    {
        return CNTK::Function::Load(filepath, computeDevice, nullptr);
    }

    static FunctionPtr Load(const char* modelBuffer, size_t length,
                            const CNTK::DeviceDescriptor& computeDevice = CNTK::DeviceDescriptor::UseDefaultDevice()) 
    {
        return CNTK::Function::Load(modelBuffer, length, computeDevice, nullptr);
    }
}

