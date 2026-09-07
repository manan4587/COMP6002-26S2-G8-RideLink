// ignore_for_file: avoid_dynamic_calls

class BaseResponse<T> {
  BaseResponse({
    required this.message,
    this.totalPage,
    this.currentPage,
    this.perPage,
    this.error,
    this.data,
    this.status,
  });

  factory BaseResponse.fromResponse(dynamic data) {
    return BaseResponse(
      data: data['data'] as T?,
      status: data['status'] as int?,
      message: data['message'] as String,
      totalPage: data['total_page'] as int?,
      currentPage: data['current_page'] as int?,
      perPage: data['per_page'] as int?,
      error: data['error'] as T?,
    );
  }
  final String message;
  final int? totalPage;
  final int? currentPage;
  final int? perPage;
  final T? error;
  final T? data;
  final int? status;

  BaseResponse copyWith({
    bool? success,
    String? message,
    int? totalPage,
    int? currentPage,
    int? perPage,
    T? error,
    T? data,
    int? status,
  }) {
    return BaseResponse(
      message: message ?? this.message,
      data: data,
      error: error,
      totalPage: totalPage ?? this.totalPage,
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'BaseResponse('
        'message: $message, '
        'Total Page: $totalPage, '
        'Current Page: $currentPage, '
        'Per Page: $perPage, '
        'error: $error, '
        'data: $data, '
        'status: $status'
        ')';
  }
}
