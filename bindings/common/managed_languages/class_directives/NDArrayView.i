%ignore CNTK::NDArrayView::NDArrayView(::CNTK::DataType dataType, const NDShape& viewShape, void* dataBuffer, size_t bufferSizeInBytes, const DeviceDescriptor& device, bool readOnly = false);
%ignore CNTK::NDArrayView::NDArrayView(::CNTK::DataType dataType, const NDShape& viewShape, const void* dataBuffer, size_t bufferSizeInBytes, const DeviceDescriptor& device);
%ignore CNTK::NDArrayView::NDArrayView(double value, DataType dataType = DataType::Float, const NDShape& viewShape = { 1 }, const DeviceDescriptor& device = DeviceDescriptor::UseDefaultDevice(), bool readOnly = false);

%extend CNTK::NDArrayView {
    NDArrayView(const NDShape& viewShape, float *dataBuffer, size_t numBufferElements, const DeviceDescriptor& device, bool readOnly = false)
    {
        if (device.Type() == CNTK::DeviceKind::GPU)
        {
            auto cpuView = new CNTK::NDArrayView(viewShape, dataBuffer, numBufferElements, CNTK::DeviceDescriptor::CPUDevice(), readOnly);
            auto gpuView = new CNTK::NDArrayView(cpuView->GetDataType(), cpuView->GetStorageFormat(), viewShape, device);
            gpuView->CopyFrom(*cpuView);
            return gpuView;
        }
        else
            return new CNTK::NDArrayView(viewShape, dataBuffer, numBufferElements, device, readOnly);
    }

    NDArrayView(const NDShape& viewShape, double *dataBuffer, size_t numBufferElements, const DeviceDescriptor& device, bool readOnly = false)
    {
        if (device.Type() == CNTK::DeviceKind::GPU)
        {
            auto cpuView = new CNTK::NDArrayView(viewShape, dataBuffer, numBufferElements, CNTK::DeviceDescriptor::CPUDevice(), readOnly);
            auto gpuView = new CNTK::NDArrayView(cpuView->GetDataType(), cpuView->GetStorageFormat(), viewShape, device);
            gpuView->CopyFrom(*cpuView);
            return gpuView;
        }
        else
            return new CNTK::NDArrayView(viewShape, dataBuffer, numBufferElements, device, readOnly);
    }

    NDArrayView(const NDShape& viewShape, const SparseIndexType* colStarts, const SparseIndexType* rowIndices, const float* nonZeroValues, size_t numNonZeroValues, const DeviceDescriptor& device, bool readOnly = false)
    {
        return new CNTK::NDArrayView(viewShape, colStarts, rowIndices, nonZeroValues, numNonZeroValues, device, readOnly);
    }

    NDArrayView(const NDShape& viewShape, const SparseIndexType* colStarts, const SparseIndexType* rowIndices, const double* nonZeroValues, size_t numNonZeroValues, const DeviceDescriptor& device, bool readOnly = false)
    {
        return new CNTK::NDArrayView(viewShape, colStarts, rowIndices, nonZeroValues, numNonZeroValues, device, readOnly);
    }

}

%rename (GetDevice) CNTK::NDArrayView::Device;
%rename (GetShape) CNTK::NDArrayView::Shape;
%rename (_IsSparse) CNTK::NDArrayView::IsSparse;
%rename (_IsReadOnly) CNTK::NDArrayView::IsReadOnly;
%rename (_SliceView) CNTK::NDArrayView::SliceView;

