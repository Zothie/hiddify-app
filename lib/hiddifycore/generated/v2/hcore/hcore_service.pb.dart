// This is a generated file - do not edit.
//
// Generated from v2/hcore/hcore_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../hcommon/common.pb.dart' as $1;
import 'hcore.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class CoreApi {
  final $pb.RpcClient _client;

  CoreApi(this._client);

  $async.Future<$0.CoreInfoResponse> start(
          $pb.ClientContext? ctx, $0.StartRequest request) =>
      _client.invoke<$0.CoreInfoResponse>(
          ctx, 'Core', 'Start', request, $0.CoreInfoResponse());
  $async.Future<$0.CoreInfoResponse> coreInfoListener(
          $pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$0.CoreInfoResponse>(
          ctx, 'Core', 'CoreInfoListener', request, $0.CoreInfoResponse());
  $async.Future<$0.OutboundGroupList> outboundsInfo(
          $pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$0.OutboundGroupList>(
          ctx, 'Core', 'OutboundsInfo', request, $0.OutboundGroupList());
  $async.Future<$0.OutboundGroupList> mainOutboundsInfo(
          $pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$0.OutboundGroupList>(
          ctx, 'Core', 'MainOutboundsInfo', request, $0.OutboundGroupList());
  $async.Future<$0.SystemInfo> getSystemInfo(
          $pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$0.SystemInfo>(
          ctx, 'Core', 'GetSystemInfo', request, $0.SystemInfo());
  $async.Future<$0.SystemInfo> getSystemInfoStream(
          $pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$0.SystemInfo>(
          ctx, 'Core', 'GetSystemInfoStream', request, $0.SystemInfo());
  $async.Future<$1.Response> setup(
          $pb.ClientContext? ctx, $0.SetupRequest request) =>
      _client.invoke<$1.Response>(ctx, 'Core', 'Setup', request, $1.Response());
  $async.Future<$0.ParseResponse> parse(
          $pb.ClientContext? ctx, $0.ParseRequest request) =>
      _client.invoke<$0.ParseResponse>(
          ctx, 'Core', 'Parse', request, $0.ParseResponse());
  $async.Future<$0.CoreInfoResponse> changeHiddifySettings(
          $pb.ClientContext? ctx, $0.ChangeHiddifySettingsRequest request) =>
      _client.invoke<$0.CoreInfoResponse>(
          ctx, 'Core', 'ChangeHiddifySettings', request, $0.CoreInfoResponse());

  /// rpc GenerateConfig (GenerateConfigRequest) returns (GenerateConfigResponse);
  $async.Future<$0.CoreInfoResponse> startService(
          $pb.ClientContext? ctx, $0.StartRequest request) =>
      _client.invoke<$0.CoreInfoResponse>(
          ctx, 'Core', 'StartService', request, $0.CoreInfoResponse());
  $async.Future<$0.CoreInfoResponse> stop(
          $pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$0.CoreInfoResponse>(
          ctx, 'Core', 'Stop', request, $0.CoreInfoResponse());
  $async.Future<$0.CoreInfoResponse> restart(
          $pb.ClientContext? ctx, $0.StartRequest request) =>
      _client.invoke<$0.CoreInfoResponse>(
          ctx, 'Core', 'Restart', request, $0.CoreInfoResponse());
  $async.Future<$1.Response> selectOutbound(
          $pb.ClientContext? ctx, $0.SelectOutboundRequest request) =>
      _client.invoke<$1.Response>(
          ctx, 'Core', 'SelectOutbound', request, $1.Response());
  $async.Future<$1.Response> urlTest(
          $pb.ClientContext? ctx, $0.UrlTestRequest request) =>
      _client.invoke<$1.Response>(
          ctx, 'Core', 'UrlTest', request, $1.Response());
  $async.Future<$1.Response> urlTestActive(
          $pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$1.Response>(
          ctx, 'Core', 'UrlTestActive', request, $1.Response());
  $async.Future<$0.WarpGenerationResponse> generateWarpConfig(
          $pb.ClientContext? ctx, $0.GenerateWarpConfigRequest request) =>
      _client.invoke<$0.WarpGenerationResponse>(ctx, 'Core',
          'GenerateWarpConfig', request, $0.WarpGenerationResponse());
  $async.Future<$0.SystemProxyStatus> getSystemProxyStatus(
          $pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$0.SystemProxyStatus>(
          ctx, 'Core', 'GetSystemProxyStatus', request, $0.SystemProxyStatus());
  $async.Future<$1.Response> setSystemProxyEnabled(
          $pb.ClientContext? ctx, $0.SetSystemProxyEnabledRequest request) =>
      _client.invoke<$1.Response>(
          ctx, 'Core', 'SetSystemProxyEnabled', request, $1.Response());
  $async.Future<$0.LogMessage> logListener(
          $pb.ClientContext? ctx, $0.LogRequest request) =>
      _client.invoke<$0.LogMessage>(
          ctx, 'Core', 'LogListener', request, $0.LogMessage());
  $async.Future<$1.Empty> close(
          $pb.ClientContext? ctx, $0.CloseRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'Core', 'Close', request, $1.Empty());
  $async.Future<$0.LANIPResponse> getLANIP(
          $pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$0.LANIPResponse>(
          ctx, 'Core', 'GetLANIP', request, $0.LANIPResponse());
  $async.Future<$0.GetAdaptiveStateResponse> getAdaptiveState(
          $pb.ClientContext? ctx, $0.GetAdaptiveStateRequest request) =>
      _client.invoke<$0.GetAdaptiveStateResponse>(ctx, 'Core',
          'GetAdaptiveState', request, $0.GetAdaptiveStateResponse());
}
