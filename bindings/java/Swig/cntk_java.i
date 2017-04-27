//JNI defines UNUSED macro as well, undefining it so it doesnt conflict with CNTKs
%{
#undef UNUSED
%}

%include "managed_languages/header.i"
%include "managed_languages/shared_ptrs.i"

%template(SizeTVector) std::vector<size_t>;
%template(DoubleVector) std::vector<double>;
%template(FloatVector) std::vector<float>;
%template(VariableVector) std::vector<CNTK::Variable>;
%template(AxisVector) std::vector<CNTK::Axis>;
%template(NDArrayViewPtrVector) std::vector<std::shared_ptr<CNTK::NDArrayView>>;
%template(BoolVector) std::vector<bool>;
%template(DeviceDescriptorVector) std::vector<CNTK::DeviceDescriptor>;
%include "managed_languages/templates.i"

%include "managed_languages/defines.i"
%include "managed_languages/ignores.i"
%include "managed_languages/array_mappings.i"

%include "CNTK_ExceptionHandling.i"

%include "managed_languages/class_directives/DeviceDescriptor.i"
%typemap(javacode) CNTK::DeviceDescriptor %{


    /*public static DeviceDescriptor GPUDevice(int deviceId)
    {
        if (deviceId < 0)
        {
            throw new System.ArgumentException("The paraemter deviceId should not be a negative value");
        }
        return GPUDevice((uint)deviceId);
    }*/

    public java.util.ArrayList<DeviceDescriptor> getAllDevices() {
        DeviceDescriptorVector devices = GetAllDevices();
        java.util.ArrayList<DeviceDescriptor> ret = new java.util.ArrayList<DeviceDescriptor>((int)devices.size());
        for (int i = 0; i < devices.size(); ++i){
            ret.add(devices.get(i));
        }
        return ret;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null) return false;
        DeviceDescriptor p = (DeviceDescriptor)o;
        if (p == null) return false;
        return CNTKLib.AreEqualDeviceDescriptor(this, p);
    }

    public boolean equals(DeviceDescriptor p) {
        if (p == null) return false;
        return CNTKLib.AreEqualDeviceDescriptor(this, p);
    }

    @Override
    public int hashCode() {
        return GetDeviceType().hashCode();
    }

    /*public static void SetExcludedDevices(System.Collections.Generic.IEnumerable<DeviceDescriptor> excluded)
    {
        var excludeVector = new DeviceDescriptorVector();
        foreach (var element in excluded)
        {
            excludeVector.Add(element);
        }
        _SetExcludedDevices(excludeVector);
    }*/
%}

%include "managed_languages/class_directives/Axis.i"
%typemap(javacode) CNTK::Axis %{

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null) return false;
        Axis p = (Axis)o;
        if (p == null) return false;
        return CNTKLib.AreEqualAxis(this, p);
    }

    public boolean equals(Axis p) {
        if (p == null) return false;
        return CNTKLib.AreEqualAxis(this, p);
    }

    @Override
    public int hashCode() {
        if (this.IsDynamicAxis()) {
            return GetName().hashCode();
        } else {
            return this.StaticAxisIndex();
        }
    }
%}

%include "managed_languages/class_directives/Function.i"
// Customize type mapping for modelBuffer, used by Load
// template taken from various.i
%apply char* INPUT { char* modelBuffer }
%typemap(jni) (char* modelBuffer) "jbyteArray"
%typemap(jtype) (char* modelBuffer) "byte[]"
%typemap(jstype) (char* modelBuffer) "byte[]"
%typemap(in) (char* modelBuffer) {
  $1 = (char *) JCALL2(GetByteArrayElements, jenv, $input, 0); 
}

%typemap(argout) (char* modelBuffer) {
  JCALL3(ReleaseByteArrayElements, jenv, $input, (jbyte *) $1, 0);
}

%typemap(javain) (char* modelBuffer) "$javainput"

/* Prevent default freearg typemap from being used */
%typemap(freearg) (char* modelBuffer) ""

%typemap(javacode) CNTK::Function %{

    public static Function Load(byte[] modelBuffer, DeviceDescriptor computeDevice)
    {
        return Load(modelBuffer, (long)modelBuffer.length, computeDevice);
    }

    // TODO: look at C# implementation and make it look more like that
    private VariableVector argumentVector;
    private VariableVector outputVector;
    private java.util.ArrayList<Variable> argumentList;
    private java.util.ArrayList<Variable> outputList;

    private UnorderedMapVariableValuePtr outMap = new UnorderedMapVariableValuePtr();

    public java.util.ArrayList<Variable> getOutputs() {
        if (outputVector == null) {
            outputVector = GetOutputs();
            outputList = new java.util.ArrayList<Variable>((int)outputVector.size());
            for (int i = 0; i < outputVector.size(); ++i){
                outputList.add(outputVector.get(i));
            }
        }
        return outputList;
    }


    public java.util.ArrayList<Variable> getArguments() {
        if (argumentVector == null) {
            argumentVector = GetArguments();
            argumentList = new java.util.ArrayList<Variable>((int)argumentVector.size());
            for (int i = 0; i < argumentVector.size(); ++i){
                argumentList.add(argumentVector.get(i));
            }
        }
        return argumentList;
    }

    /*public System.Collections.Generic.IList<Variable> Inputs
    {
        get {
            var varVector = GetInputs();
            var varArray = new Variable[varVector.Count];
            // The CopyTo is to ensure that elements in varVector live beyond the lifecycle of varVector.
            varVector.CopyTo(varArray);
            var varList = new System.Collections.Generic.List<Variable>(varArray);
            return varList;
        }
    }*/

    public static Function Combine(java.util.ArrayList<Variable> outputVariable) {
        VariableVector varVect = new VariableVector();
        for (int i = 0; i < outputVariable.size(); ++i)
        {
            varVect.add(varVect.get(i));
        }
        return CNTKLib.Combine(varVect);
    }

    /*public static Function AsComposite(Function rootFunction, string name = "")
    {
        return CNTKLib.AsComposite(rootFunction, name);
    }*/

    /*public static Function Alias(Variable operand, string name = "")
    {
        return CNTKLib.Alias(operand, name);
    }*/

    /*// For C# Eval, default ParameterCloningMethod is share.
    public Function Clone(ParameterCloningMethod parameterCloneMethod = ParameterCloningMethod.Share)
    {
        return _Clone(ParameterCloningMethod.Share);
    }*/

    /*public void Evaluate(System.Collections.Generic.IDictionary<Variable, Value> inputs, System.Collections.Generic.IDictionary<Variable, Value> outputs, DeviceDescriptor computeDevice)
    {
        Evaluate(inputs, outputs, false, computeDevice);
    }*/

    /*public void Evaluate(System.Collections.Generic.IDictionary<Variable, Value> inputs, System.Collections.Generic.IDictionary<Variable, Value> outputs, bool createPersistentOutputValues, DeviceDescriptor computeDevice)
    {
        // Evaluate the rootFunction.
        var inMap = new UnorderedMapVariableValuePtr();
        var outMap = new UnorderedMapVariableValuePtr();
        foreach (var p in inputs)
        {
            inMap.Add(p.Key, p.Value);
        }

        foreach (var p in outputs)
        {
            outMap.Add(p.Key, p.Value);
        }

        Evaluate(inMap, outMap, computeDevice);

        foreach (var p in outMap)
        {
            if (createPersistentOutputValues && (outputs[p.Key] == null))
            {
                outputs[p.Key] = p.Value.DeepClone();
            }
            else
            { 
                // for shared_ptr<Value>, the p.Value returns a copy, so it is safe to use it directly in outputs.
                outputs[p.Key] = p.Value;
            }
        }
    }*/

    /*public System.Collections.Generic.IList<Function> FindAllWithName(string name, bool nestedSearchInsideBlockFunction = false)
    {
        var funcPtrVector = _FindAllWithName(name, nestedSearchInsideBlockFunction);
        var funcPtrList = new System.Collections.Generic.List<Function>(funcPtrVector.Count);
        for (int i = 0; i < funcPtrVector.Count; i++)
        {
            // for shared_ptr, the funcPtrVector[i] returns a copy, so it is safe to directly use it in return list.
            funcPtrList.Add(funcPtrVector[i]);
        }
        return funcPtrList;
    }*/
%}

%include "managed_languages/class_directives/Variable.i"
%typemap(javacode) CNTK::Variable %{

    /*public System.Collections.Generic.IList<Axis> DynamicAxes
    {
        get {
            var axisVector = GetDynamicAxes();
            // The CopyTo is to ensure that elements in axisVector live beyond the lifecycle of axisVector.
            var axisArray = new Axis[axisVector.Count];
            axisVector.CopyTo(axisArray);
            var axisList = new System.Collections.Generic.List<Axis>(axisArray);
            return axisList;
        }
    }*/

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null) return false;
        Variable p = (Variable)o;
        if (p == null) return false;
        return CNTKLib.AreEqualVariable(this, p);
    }

    public boolean equals(Variable p) {
        if (p == null) return false;
        return CNTKLib.AreEqualVariable(this, p);
    }

    @Override
    public int hashCode() {
        return (int)GetHashValue();
    }
%}

%include "managed_languages/class_directives/NDShape.i"
%typemap(javacode) CNTK::NDShape %{

    /*public NDShape(int numAxes, int dimension) : this((uint)numAxes, (uint)dimension)
    {
        if (numAxes < 0 || dimension < 0)
        {
            throw new System.ArgumentException("The paraemter numAxes or dimension should not be a negative value");
        }
    }*/

    /*public NDShape(int numAxes) : this((uint)numAxes)
    {
        if (numAxes < 0)
        {
            throw new System.ArgumentException("The paraemter numAxes should not be a negative value");
        }
    }*/

    public java.util.ArrayList<Long> getDimensions(){
        java.util.ArrayList<Long> ret = new java.util.ArrayList<Long>((int)GetRank());
        for (int i = 0; i < GetDimensions().size(); ++i ) {
            ret.add((Long)GetDimensions().get(i));
        }
        return ret;
    }

    /*public NDShape SubShape(int beginAxisId, int endAxisId)
    {
        if (beginAxisId < 0 || endAxisId < 0)
        {
            throw new System.ArgumentException("The paraemter beginAxisId or endAxisId should not be a negative value");
        }
        return SubShape((uint)beginAxisId, (uint)endAxisId);
    }*/

    /*public NDShape SubShape(int beginAxisId)
    {
        if (beginAxisId < 0)
        {
            throw new System.ArgumentException("The paraemter beginAxisId should not be a negative value");
        }
        return SubShape((uint)beginAxisId);
    }*/

    /*public static NDShape CreateNDShape(System.Collections.Generic.IEnumerable<int> dimensions)
    {
        var dimVector = new SizeTVector();
        foreach (var element in dimensions)
        {
            if (element < 0)
            {
                throw new System.ArgumentException("The paraemter diemnsions cannot contain a negative value");
            }
            dimVector.Add((uint)element);
        }
        return new NDShape(dimVector);
    }*/

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null) return false;
        NDShape p = (NDShape)o;
        if (p == null) return false;
        return CNTKLib.AreEqualShape(this, p);
    }

    public boolean equals(NDShape p) {
        if (p == null) return false;
        return CNTKLib.AreEqualShape(this, p);
    }

    @Override
    public int hashCode() {
        return GetDimensions().hashCode();
    }

    /*public static readonly int InferredDimension = -1;
    public static readonly int FreeDimension = -3;*/
%}

%include "managed_languages/class_directives/NDMask.i"
%typemap(javacode) CNTK::NDMask %{
    /*public void InvalidateSection(System.Collections.Generic.IEnumerable<int> sectionOffset, NDShape sectionShape) {
        var offsetVector = AsSizeTVector(sectionOffset);
        _InvalidateSection(offsetVector, sectionShape);
    }*/

    /*public void MarkSequenceBegin(System.Collections.Generic.IEnumerable<int> offset) {
        var offsetVector = AsSizeTVector(offset);
        _MarkSequenceBegin(offsetVector);
    }*/

    /*public void MarkSequenceBegin(System.Collections.Generic.IEnumerable<int> offset, NDShape sectionShape) {
        var offsetVector = AsSizeTVector(offset);
        _MarkSequenceBegin(offsetVector, sectionShape);
    }*/

    /*private static SizeTVector AsSizeTVector(System.Collections.Generic.IEnumerable<int> input)
    {
        var inputVector = new SizeTVector();
        foreach (var element in input)
        {
            if (element < 0)
            {
                throw new System.ArgumentException("The argument cannot contain a negative value");
            }
            inputVector.Add((uint)element);
        }
        return inputVector;
    }*/
%}

%include "managed_languages/class_directives/Value.i"
%typemap(javacode) CNTK::Value %{

    /*// Create Value object from dense input: batch, sequence or batch of sequences.
    public static Value CreateBatch<T>(NDShape sampleShape, System.Collections.Generic.IEnumerable<T> batch, DeviceDescriptor device, bool readOnly = false)
    {
        if (typeof(T).Equals(typeof(float)))
        {
            var inputVector = AsFloatVector(batch);
            return Value.CreateBatchFloat(sampleShape, inputVector, device, readOnly);
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            var inputVector = AsDoubleVector(batch);
            return Value.CreateBatchDouble(sampleShape, inputVector, device, readOnly);
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    public static Value CreateSequence<T>(NDShape sampleShape,
                                          System.Collections.Generic.IEnumerable<T> sequence,
                                          DeviceDescriptor device,
                                          bool readOnly = false)
    {
        return CreateSequence<T>(sampleShape, sequence, true, device, readOnly);
    }

    public static Value CreateSequence<T>(NDShape sampleShape,
                                          System.Collections.Generic.IEnumerable<T> sequence,
                                          bool sequenceStartFlag,
                                          DeviceDescriptor device,
                                          bool readOnly = false)
    {
        if (typeof(T).Equals(typeof(float)))
        {
            var inputVector = AsFloatVector(sequence);
            return Value.CreateSequenceFloat(sampleShape, inputVector, sequenceStartFlag, device, readOnly);
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            var inputVector = AsDoubleVector(sequence);
            return Value.CreateSequenceDouble(sampleShape, inputVector, sequenceStartFlag, device, readOnly);
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    public static Value CreateBatchOfSequences<T>(NDShape sampleShape,
                                                  System.Collections.Generic.IEnumerable<System.Collections.Generic.IEnumerable<T>> batchOfSequences,
                                                  DeviceDescriptor device,
                                                  bool readOnly = false)
    {
        return Create(sampleShape, batchOfSequences, new System.Collections.Generic.List<bool>(0), device, readOnly);
    }

    public static Value CreateBatchOfSequences<T>(NDShape sampleShape,
                                                  System.Collections.Generic.IEnumerable<System.Collections.Generic.IEnumerable<T>> batchOfSequences,
                                                  System.Collections.Generic.IEnumerable<bool> sequenceStartFlags,
                                                  DeviceDescriptor device,
                                                  bool readOnly = false)
    {
        return Create(sampleShape, batchOfSequences, sequenceStartFlags, device, readOnly);
    }

    public static Value Create<T>(NDShape sampleShape,
                                  System.Collections.Generic.IEnumerable<System.Collections.Generic.IEnumerable<T>> sequences,
                                  System.Collections.Generic.IEnumerable<bool> sequenceStartFlags,
                                  DeviceDescriptor device,
                                  bool readOnly = false)
    {
        var seqFlags = AsBoolVector(sequenceStartFlags);
        if (typeof(T).Equals(typeof(float)))
        {
            var inputAsSequencesVector = new FloatVectorVector();
            foreach (var seq in sequences)
            {
                var seqVector = AsFloatVector(seq);
                // The seqVector is copied when adding to inputAsSequencesVector.
                inputAsSequencesVector.Add(seqVector);
            }
            return Value.CreateDenseFloat(sampleShape, inputAsSequencesVector, seqFlags, device, readOnly);
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            var inputAsSequencesVector = new DoubleVectorVector();
            foreach (var seq in sequences)
            {
                var seqVector = AsDoubleVector(seq);
                inputAsSequencesVector.Add(seqVector);
            }
            return Value.CreateDenseDouble(sampleShape, inputAsSequencesVector, seqFlags, device, readOnly);
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    // Create Value object from OneHotVector input, for N-dimenstional tensor. Only Create() method for now.
    public static Value Create<T>(NDShape sampleShape,
                                  System.Collections.Generic.IEnumerable<System.Collections.Generic.IEnumerable<int>> sequences,
                                  System.Collections.Generic.IEnumerable<bool> sequenceStartFlags,
                                  DeviceDescriptor device,
                                  bool readOnly = false)
    {
        var seqFlags = AsBoolVector(sequenceStartFlags);
        var inputSeqVector = new SizeTVectorVector();
        foreach (var seq in sequences)
        {
            var s = AsSizeTVector(seq);
            inputSeqVector.Add(s);
        }
        if (typeof(T).Equals(typeof(float)))
        {
            return Value.CreateOneHotFloat(sampleShape, inputSeqVector, seqFlags, device, readOnly);
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            return Value.CreateOneHotDouble(sampleShape, inputSeqVector, seqFlags, device, readOnly);
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    // Create Value object from OneHotVector input, for 1D tensor: batch, sequence or batch of sequences
    public static Value CreateBatch<T>(int dimension, System.Collections.Generic.IEnumerable<int> batch, DeviceDescriptor device, bool readOnly = false)
    {
        var inputVector = AsSizeTVector(batch);
        if (typeof(T).Equals(typeof(float)))
        {
            return Value.CreateBatchFloat((uint)dimension, inputVector, device, readOnly);
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            return Value.CreateBatchDouble((uint)dimension, inputVector, device, readOnly);
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    public static Value CreateSequence<T>(int dimension,
                                          System.Collections.Generic.IEnumerable<int> sequence,
                                          DeviceDescriptor device,
                                          bool readOnly = false)
    {
        return CreateSequence<T>(dimension, sequence, true, device, readOnly);
    }

    public static Value CreateSequence<T>(int dimension,
                                          System.Collections.Generic.IEnumerable<int> sequence,
                                          bool sequenceStartFlag,
                                          DeviceDescriptor device,
                                          bool readOnly = false)
    {
        var inputVector = AsSizeTVector(sequence);
        if (typeof(T).Equals(typeof(float)))
        {
            return Value.CreateSequenceFloat((uint)dimension, inputVector, sequenceStartFlag, device, readOnly);
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            return Value.CreateSequenceDouble((uint)dimension, inputVector, sequenceStartFlag, device, readOnly);
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    public static Value CreateBatchOfSequences<T>(int dimension,
                                                  System.Collections.Generic.IEnumerable<System.Collections.Generic.IEnumerable<int>> batchOfSequences,
                                                  DeviceDescriptor device,
                                                  bool readOnly = false)
    {
        return Create<T>(dimension, batchOfSequences, new System.Collections.Generic.List<bool>(0), device, readOnly);
    }

    public static Value CreateBatchOfSequences<T>(int dimension,
                                                  System.Collections.Generic.IEnumerable<System.Collections.Generic.IEnumerable<int>> batchOfSequences,
                                                  System.Collections.Generic.IEnumerable<bool> sequenceStartFlags,
                                                  DeviceDescriptor device,
                                                  bool readOnly = false)
    {
        return Create<T>(dimension, batchOfSequences, sequenceStartFlags, device, readOnly);
    }

    public static Value Create<T>(int dimension,
                                  System.Collections.Generic.IEnumerable<System.Collections.Generic.IEnumerable<int>> sequences,
                                  System.Collections.Generic.IEnumerable<bool> sequenceStartFlags,
                                  DeviceDescriptor device,
                                  bool readOnly = false)
    {
        var seqFlags = AsBoolVector(sequenceStartFlags);
        var inputSeqVector = new SizeTVectorVector();
        foreach (var seq in sequences)
        {
            var s = AsSizeTVector(seq);
            inputSeqVector.Add(s);
        }
        if (typeof(T).Equals(typeof(float)))
        {
            return Value.CreateOneHotFloat((uint)dimension, inputSeqVector, seqFlags, device, readOnly);
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            return Value.CreateOneHotDouble((uint)dimension, inputSeqVector, seqFlags, device, readOnly);
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    // Create Value object from sparse input, for N-dimensional tensor. Only CreateSequence() for now.
    public static Value CreateSequence<T>(NDShape sampleShape, int sequenceLength,
                                          int[] colStarts, int[] rowIndices, T[] nonZeroValues,
                                          bool sequenceStartFlag,
                                          DeviceDescriptor device,
                                          bool readOnly = false)
    {
        if (nonZeroValues.Length != rowIndices.Length)
        {
            throw new System.ArgumentException("The length of rowIndicies must be same as the length of nonZeroValues.");
        }
        if (colStarts.Length != sequenceLength + 1)
        {
            throw new System.ArgumentException("The length of colStarts must be equal to (sequenceLength + 1)");
        }
        uint numNonZeroValues = (uint)nonZeroValues.Length;

        if (typeof(T).Equals(typeof(float)))
        {
            return Value.CreateSequenceFloat(sampleShape, (uint)sequenceLength, colStarts, rowIndices, nonZeroValues as float[], numNonZeroValues, sequenceStartFlag, device, readOnly);
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            return Value.CreateSequenceDouble(sampleShape, (uint)sequenceLength, colStarts, rowIndices, nonZeroValues as double[], numNonZeroValues, sequenceStartFlag, device, readOnly);
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    public static Value CreateSequence<T>(NDShape sampleShape, int sequenceLength,
                                          int[] colStarts, int[] rowIndices, T[] nonZeroValues,
                                          DeviceDescriptor device,
                                          bool readOnly = false)
    {
        return Value.CreateSequence<T>(sampleShape, sequenceLength, colStarts, rowIndices, nonZeroValues, true, device, readOnly);
    }

    // Create Value object from sparse input, for 1D tensor. Only CreateSequence() for now.
    public static Value CreateSequence<T>(int dimension, int sequenceLength,
                                          int[] colStarts, int[] rowIndices, T[] nonZeroValues,
                                          bool sequenceStartFlag,
                                          DeviceDescriptor device,
                                          bool readOnly = false)
    {
        if (nonZeroValues.Length != rowIndices.Length)
        {
            throw new System.ArgumentException("The length of rowIndicies must be same as the length of nonZeroValues.");
        }
        if (colStarts.Length != sequenceLength + 1)
        {
            throw new System.ArgumentException("The length of colStarts must be equal to (sequenceLength + 1)");
        }
        uint numNonZeroValues = (uint)nonZeroValues.Length;

        if (typeof(T).Equals(typeof(float)))
        {
            return Value.CreateSequenceFloat((uint)dimension, (uint)sequenceLength, colStarts, rowIndices, nonZeroValues as float[], numNonZeroValues, sequenceStartFlag, device, readOnly);
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            return Value.CreateSequenceDouble((uint)dimension, (uint)sequenceLength, colStarts, rowIndices, nonZeroValues as double[], numNonZeroValues, sequenceStartFlag, device, readOnly);
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    public static Value CreateSequence<T>(int dimension, int sequenceLength,
                                          int[] colStarts, int[] rowIndices, T[] nonZeroValues,
                                          DeviceDescriptor device,
                                          bool readOnly = false)
    {
        return Value.CreateSequence<T>(dimension, sequenceLength, colStarts, rowIndices, nonZeroValues, true, device, readOnly);
    }

    // Create value object from NDArrayView
    public static Value Create(NDShape sampleShape,
                               System.Collections.Generic.IEnumerable<NDArrayView> sequences,
                               DeviceDescriptor device,
                               bool readOnly = false)
    {
        return Create(sampleShape, sequences, new System.Collections.Generic.List<bool>(0), device, readOnly);
    }

    public static Value Create(NDShape sampleShape,
                               System.Collections.Generic.IEnumerable<NDArrayView> sequences,
                               System.Collections.Generic.IEnumerable<bool> sequenceStartFlags,
                               DeviceDescriptor device,
                               bool readOnly = false)
    {
        var seqVector = new NDArrayViewPtrVector();
        foreach (var element in sequences)
        {
            seqVector.Add(element);
        }
        var startFlags = AsBoolVector(sequenceStartFlags);
        return Create(sampleShape, seqVector, startFlags, device, false);
    }

    //
    // Return the data of the Value object as a list of sequences with variable length.
    // This method returns an IList<IList<T>>. Each element of the outer list represents a sequence.
    // Each sequence, represented by IList<T>, contains a variable number of samples.
    // Each sample consits of a fixed number of elements with type of 'T'. The number of elements is determined by the variable shape.
    // The number of samples = (the count of elements in IList<T>)/(the count of elements of the sample)
    // The shape of the variable should match the shape of the Value object.
    //
    public System.Collections.Generic.IList<System.Collections.Generic.IList<T>> GetDenseData<T>(Variable outputVariable)
    {
        var sequences = new System.Collections.Generic.List<System.Collections.Generic.IList<T>>();
        if (typeof(T).Equals(typeof(float)))
        {
            if (GetDataType() != DataType.Float)
            {
                throw new System.ArgumentException("The value type does not match the list type.");
            }

            var seqVec = new FloatVectorVector();
            CopyVariableValueToFloat(outputVariable, seqVec);

            foreach (var seq in seqVec)
            {
                var seqList = seq as System.Collections.Generic.IList<T>;
                if (seqList == null)
                    throw new System.TypeAccessException("Cannot convert to the value type.");
                // It is required to create a new List from seq, since seq is dependent on the life cycle of seqVec.
                sequences.Add(new System.Collections.Generic.List<T>(seqList));
            }
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            if (GetDataType() != DataType.Double)
            {
                throw new System.ArgumentException("The value type does not match the list type.");
            }

            var seqVec = new DoubleVectorVector();
            CopyVariableValueToDouble(outputVariable, seqVec);
            foreach (var seq in seqVec)
            {
                var seqList = seq as System.Collections.Generic.IList<T>;
                if (seqList == null)
                    throw new System.TypeAccessException("Cannot convert to the value type.");
                // It is required to create a new List from seq, since seq is dependent on the life cycle of seqVec.
                sequences.Add(new System.Collections.Generic.List<T>(seqList));
            }
        }
        else
        {
            throw new System.ArgumentException("The value type does not match the list type.");
        }
        return sequences;
    }*/

    /*
    //
    // Return the data of the Value object as a list of sequences with variable length.
    // This method returns an IList<IList<T>>. Each element of the outer list represents a sequence.
    // Each sequence, represented by List<int>, contains a variable number of samples.
    // Each sample is represented by an index of the OneHot vector. The size of the OneHot vector should match that defined in the variable.
    // The number of samples = the count of elements in List<int>.
    //
    public System.Collections.Generic.IList<System.Collections.Generic.IList<int>> GetOneHotData(Variable outputVariable)
    {
        var sequences = new System.Collections.Generic.List<System.Collections.Generic.IList<int>>();
        var seqVec = new SizeTVectorVector();
        CopyVariableValueTo(outputVariable, seqVec);
        foreach(var seq in seqVec)
        {
            var seqList = new System.Collections.Generic.List<int>(seq.Count);
            foreach (var element in seq)
            {
                seqList.Add((int)element);
            }
            sequences.Add(seqList);
        }
        return sequences;
    }

    //
    // Copy the data of the Value object into the buffer provided by 'sequences'.
    // The 'sequences' is a list of sequences with variable length. 
    // The number of items contained in the outer list of 'sequences' is the number of sequences in the Value object.
    // Each element of the outer list represents a sequence.
    // Each sequence, represented by List<T>, contains a variable number of samples. 
    // Each sample consits of a fixed number of elements with type of 'T'. The number of elements is determined by the variable shape.
    // The number of samples = the count of elements in List<T> / the count of elements of the sample
    // The shape of the variable should match the shape of the Value object.
    //
    [System.Obsolete("CopyVariableValueTo() will be deprecated soon. Please use GetDenseData() instead.")]
    public void CopyVariableValueTo<T>(Variable outputVariable, System.Collections.Generic.List<System.Collections.Generic.List<T>> sequences)
    {
        sequences.Clear();
        if (typeof(T).Equals(typeof(float)))
        {
            if (GetDataType() != DataType.Float)
            {
                throw new System.ArgumentException("The value type does not match the list type.");
            }

            var seqVec = new FloatVectorVector();
            CopyVariableValueToFloat(outputVariable, seqVec);

            foreach (var seq in seqVec)
            {
                var seqList = seq as System.Collections.Generic.IList<T>;
                if (seqList == null)
                    throw new System.TypeAccessException("Cannot convert to the value type.");
                sequences.Add(new System.Collections.Generic.List<T>(seqList));
            }
        }
        else if (typeof(T).Equals(typeof(double)))
        {
            if (GetDataType() != DataType.Double)
            {
                throw new System.ArgumentException("The value type does not match the list type.");
            }

            var seqVec = new DoubleVectorVector();
            CopyVariableValueToDouble(outputVariable, seqVec);
            foreach (var seq in seqVec)
            {
                var seqList = seq as System.Collections.Generic.IList<T>;
                if (seqList == null)
                    throw new System.TypeAccessException("Cannot convert to the value type.");
                sequences.Add(new System.Collections.Generic.List<T>(seqList));
            }
        }
        else
        {
            throw new System.ArgumentException("The value type does not match the list type.");
        }
    }

    //
    // Copy the data of the Value object into the buffer provided by 'sequences'.
    // The 'sequences' is a list of sequences with variable length.
    // The number of items contained in the outer list of 'sequences' is the number of sequences in the Value object.
    // Each element of the outer list represents a sequence.
    // Each sequence, represented by List<int>, contains a variable number of samples.
    // Each sample is represented by an index of the OneHot vector. The size of the OneHot vector should match that defined in the variable. 
    // The number of samples = the count of elements in List<int>.
    //
    [System.Obsolete("CopyVariableValueTo() will be deprecated soon. Please use GetOneHotData() instead.")]
    public void CopyVariableValueTo(Variable outputVariable, System.Collections.Generic.List<System.Collections.Generic.List<int>> sequences)
    {
        var seqVec = new SizeTVectorVector();
        CopyVariableValueTo(outputVariable, seqVec);

        sequences.Clear();
        foreach(var seq in seqVec)
        {
            var seqList = new System.Collections.Generic.List<int>(seq.Count);
            foreach (var element in seq)
            {
                seqList.Add((int)element);
            }
            sequences.Add(seqList);
        }
        return;
    }

    private static FloatVector AsFloatVector<T>(System.Collections.Generic.IEnumerable<T> input)
    {
        if (typeof(T).Equals(typeof(float)))
        {
            var inputVector = new FloatVector();
            System.Collections.Generic.IEnumerable<float> inputInType = input as System.Collections.Generic.IEnumerable<float>;
            if (inputInType == null)
                throw new System.ArgumentNullException("The parameter cannot be cast as IEnumerable<float>.");
            foreach (var element in inputInType)
            {
                inputVector.Add(element);
            }
            return inputVector;
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    private static DoubleVector AsDoubleVector<T>(System.Collections.Generic.IEnumerable<T> input)
    {
        if (typeof(T).Equals(typeof(double)))
        {
            var inputVector = new DoubleVector();
            System.Collections.Generic.IEnumerable<double> inputInType = input as System.Collections.Generic.IEnumerable<double>;
            if (inputInType == null)
                throw new System.ArgumentNullException("The parameter cannot be cast as IEnumerable<double>.");
            foreach (var element in inputInType)
            {
                inputVector.Add(element);
            }
            return inputVector;
        }
        else
        {
            throw new System.ArgumentException("The data type " + typeof(T).ToString() + " is not supported. Only float or double is supported by CNTK.");
        }
    }

    private static SizeTVector AsSizeTVector(System.Collections.Generic.IEnumerable<int> input)
    {
        var inputVector = new SizeTVector();
        foreach (var element in input)
        {
            inputVector.Add((uint)element);
        }
        return inputVector;
    }

    private static BoolVector AsBoolVector(System.Collections.Generic.IEnumerable<bool> input)
    {
        var inputVector = new BoolVector();
        foreach (var element in input)
        {
            inputVector.Add(element);
        }
        return inputVector;
    }*/
%}

%include "managed_languages/class_directives/NDArrayView.i"
%typemap(javacode) CNTK::NDArrayView %{
    /*public NDArrayView(NDShape viewShape, float[] dataBuffer, DeviceDescriptor device, bool readOnly = false) : this(viewShape, dataBuffer, (uint)dataBuffer.Length, device, readOnly)
    {
    }

    public NDArrayView(NDShape viewShape, double[] dataBuffer, DeviceDescriptor device, bool readOnly = false) : this(viewShape, dataBuffer, (uint)dataBuffer.Length, device, readOnly)
    {
    }

    public NDArrayView(NDShape viewShape, int[] colStarts, int[] rowIndices, float[] nonZeroValues, DeviceDescriptor device, bool readOnly = false) : this(viewShape, colStarts, rowIndices, nonZeroValues, (uint)nonZeroValues.Length, device, readOnly)
    {
        if (rowIndices.Length != nonZeroValues.Length)
        {
            throw new System.ArgumentException("The length of rowIndicies must be same as the length of nonZeroValues.");
        }
        if (viewShape[viewShape.Rank-1] + 1 != colStarts.Length)
        {
            throw new System.ArgumentException("The length of colStarts does not match the number of rows, i.e. the dimension size of the last rank of viewShape.");
        }
    }

    public NDArrayView(NDShape viewShape, int[] colStarts, int[] rowIndices, double[] nonZeroValues, DeviceDescriptor device, bool readOnly = false) : this(viewShape, colStarts, rowIndices, nonZeroValues, (uint)nonZeroValues.Length, device, readOnly)
    {
        if (rowIndices.Length != nonZeroValues.Length)
        {
            throw new System.ArgumentException("The length of rowIndicies must be same as the length of nonZeroValues.");
        }
        if (viewShape[viewShape.Rank-1] + 1 != colStarts.Length)
        {
            throw new System.ArgumentException("The length of colStarts does not match the number of rows, i.e. the dimension size of the last rank of viewShape.");
        }
    }*/

    /*public NDArrayView SliceView(System.Collections.Generic.IEnumerable<int> startOffset, System.Collections.Generic.IEnumerable<int> extent, bool readOnly = false)
    {
        var startOffsetVector = AsSizeTVector(startOffset);

        var extentVector = AsSizeTVector(extent);

        return _SliceView(startOffsetVector, extentVector, readOnly);
    }

    private static SizeTVector AsSizeTVector(System.Collections.Generic.IEnumerable<int> input)
    {
        var inputVector = new SizeTVector();
        foreach (var element in input)
        {
            if (element < 0)
            {
                throw new System.ArgumentException("The argument cannot contain a negative value");
            }
            inputVector.Add((uint)element);
        }
        return inputVector;
    }*/
%}

%include "CNTKLibraryInternals.h"
%include "CNTKLibrary.h"
