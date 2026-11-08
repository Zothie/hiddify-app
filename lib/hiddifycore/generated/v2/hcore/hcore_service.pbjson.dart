// This is a generated file - do not edit.
//
// Generated from v2/hcore/hcore_service.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../google/protobuf/timestamp.pbjson.dart' as $2;
import '../hcommon/common.pbjson.dart' as $1;
import 'hcore.pbjson.dart' as $0;

const $core.Map<$core.String, $core.dynamic> CoreServiceBase$json = {
  '1': 'Core',
  '2': [
    {'1': 'Start', '2': '.hcore.StartRequest', '3': '.hcore.CoreInfoResponse'},
    {
      '1': 'CoreInfoListener',
      '2': '.hcommon.Empty',
      '3': '.hcore.CoreInfoResponse',
      '6': true
    },
    {
      '1': 'OutboundsInfo',
      '2': '.hcommon.Empty',
      '3': '.hcore.OutboundGroupList',
      '6': true
    },
    {
      '1': 'MainOutboundsInfo',
      '2': '.hcommon.Empty',
      '3': '.hcore.OutboundGroupList',
      '6': true
    },
    {'1': 'GetSystemInfo', '2': '.hcommon.Empty', '3': '.hcore.SystemInfo'},
    {
      '1': 'GetSystemInfoStream',
      '2': '.hcommon.Empty',
      '3': '.hcore.SystemInfo',
      '6': true
    },
    {'1': 'Setup', '2': '.hcore.SetupRequest', '3': '.hcommon.Response'},
    {'1': 'Parse', '2': '.hcore.ParseRequest', '3': '.hcore.ParseResponse'},
    {
      '1': 'ChangeHiddifySettings',
      '2': '.hcore.ChangeHiddifySettingsRequest',
      '3': '.hcore.CoreInfoResponse'
    },
    {
      '1': 'StartService',
      '2': '.hcore.StartRequest',
      '3': '.hcore.CoreInfoResponse'
    },
    {'1': 'Stop', '2': '.hcommon.Empty', '3': '.hcore.CoreInfoResponse'},
    {
      '1': 'Restart',
      '2': '.hcore.StartRequest',
      '3': '.hcore.CoreInfoResponse'
    },
    {
      '1': 'SelectOutbound',
      '2': '.hcore.SelectOutboundRequest',
      '3': '.hcommon.Response'
    },
    {'1': 'UrlTest', '2': '.hcore.UrlTestRequest', '3': '.hcommon.Response'},
    {'1': 'UrlTestActive', '2': '.hcommon.Empty', '3': '.hcommon.Response'},
    {
      '1': 'GenerateWarpConfig',
      '2': '.hcore.GenerateWarpConfigRequest',
      '3': '.hcore.WarpGenerationResponse'
    },
    {
      '1': 'GetSystemProxyStatus',
      '2': '.hcommon.Empty',
      '3': '.hcore.SystemProxyStatus'
    },
    {
      '1': 'SetSystemProxyEnabled',
      '2': '.hcore.SetSystemProxyEnabledRequest',
      '3': '.hcommon.Response'
    },
    {
      '1': 'LogListener',
      '2': '.hcore.LogRequest',
      '3': '.hcore.LogMessage',
      '6': true
    },
    {'1': 'Close', '2': '.hcore.CloseRequest', '3': '.hcommon.Empty'},
    {'1': 'GetLANIP', '2': '.hcommon.Empty', '3': '.hcore.LANIPResponse'},
    {
      '1': 'GetAdaptiveState',
      '2': '.hcore.GetAdaptiveStateRequest',
      '3': '.hcore.GetAdaptiveStateResponse'
    },
  ],
};

@$core.Deprecated('Use coreServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    CoreServiceBase$messageJson = {
  '.hcore.StartRequest': $0.StartRequest$json,
  '.hcore.CoreInfoResponse': $0.CoreInfoResponse$json,
  '.hcommon.Empty': $1.Empty$json,
  '.hcore.OutboundGroupList': $0.OutboundGroupList$json,
  '.hcore.OutboundGroup': $0.OutboundGroup$json,
  '.hcore.OutboundInfo': $0.OutboundInfo$json,
  '.google.protobuf.Timestamp': $2.Timestamp$json,
  '.hcore.IpInfo': $0.IpInfo$json,
  '.hcore.SystemInfo': $0.SystemInfo$json,
  '.hcore.SetupRequest': $0.SetupRequest$json,
  '.hcommon.Response': $1.Response$json,
  '.hcore.ParseRequest': $0.ParseRequest$json,
  '.hcore.ParseResponse': $0.ParseResponse$json,
  '.hcore.ChangeHiddifySettingsRequest': $0.ChangeHiddifySettingsRequest$json,
  '.hcore.SelectOutboundRequest': $0.SelectOutboundRequest$json,
  '.hcore.UrlTestRequest': $0.UrlTestRequest$json,
  '.hcore.GenerateWarpConfigRequest': $0.GenerateWarpConfigRequest$json,
  '.hcore.WarpGenerationResponse': $0.WarpGenerationResponse$json,
  '.hcore.WarpAccount': $0.WarpAccount$json,
  '.hcore.WarpWireguardConfig': $0.WarpWireguardConfig$json,
  '.hcore.SystemProxyStatus': $0.SystemProxyStatus$json,
  '.hcore.SetSystemProxyEnabledRequest': $0.SetSystemProxyEnabledRequest$json,
  '.hcore.LogRequest': $0.LogRequest$json,
  '.hcore.LogMessage': $0.LogMessage$json,
  '.hcore.CloseRequest': $0.CloseRequest$json,
  '.hcore.LANIPResponse': $0.LANIPResponse$json,
  '.hcore.GetAdaptiveStateRequest': $0.GetAdaptiveStateRequest$json,
  '.hcore.GetAdaptiveStateResponse': $0.GetAdaptiveStateResponse$json,
  '.hcore.GetAdaptiveStateResponse.PerCandidateEntry':
      $0.GetAdaptiveStateResponse_PerCandidateEntry$json,
};

/// Descriptor for `Core`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List coreServiceDescriptor = $convert.base64Decode(
    'CgRDb3JlEjUKBVN0YXJ0EhMuaGNvcmUuU3RhcnRSZXF1ZXN0GhcuaGNvcmUuQ29yZUluZm9SZX'
    'Nwb25zZRI9ChBDb3JlSW5mb0xpc3RlbmVyEg4uaGNvbW1vbi5FbXB0eRoXLmhjb3JlLkNvcmVJ'
    'bmZvUmVzcG9uc2UwARI7Cg1PdXRib3VuZHNJbmZvEg4uaGNvbW1vbi5FbXB0eRoYLmhjb3JlLk'
    '91dGJvdW5kR3JvdXBMaXN0MAESPwoRTWFpbk91dGJvdW5kc0luZm8SDi5oY29tbW9uLkVtcHR5'
    'GhguaGNvcmUuT3V0Ym91bmRHcm91cExpc3QwARIyCg1HZXRTeXN0ZW1JbmZvEg4uaGNvbW1vbi'
    '5FbXB0eRoRLmhjb3JlLlN5c3RlbUluZm8SOgoTR2V0U3lzdGVtSW5mb1N0cmVhbRIOLmhjb21t'
    'b24uRW1wdHkaES5oY29yZS5TeXN0ZW1JbmZvMAESLwoFU2V0dXASEy5oY29yZS5TZXR1cFJlcX'
    'Vlc3QaES5oY29tbW9uLlJlc3BvbnNlEjIKBVBhcnNlEhMuaGNvcmUuUGFyc2VSZXF1ZXN0GhQu'
    'aGNvcmUuUGFyc2VSZXNwb25zZRJVChVDaGFuZ2VIaWRkaWZ5U2V0dGluZ3MSIy5oY29yZS5DaG'
    'FuZ2VIaWRkaWZ5U2V0dGluZ3NSZXF1ZXN0GhcuaGNvcmUuQ29yZUluZm9SZXNwb25zZRI8CgxT'
    'dGFydFNlcnZpY2USEy5oY29yZS5TdGFydFJlcXVlc3QaFy5oY29yZS5Db3JlSW5mb1Jlc3Bvbn'
    'NlEi8KBFN0b3ASDi5oY29tbW9uLkVtcHR5GhcuaGNvcmUuQ29yZUluZm9SZXNwb25zZRI3CgdS'
    'ZXN0YXJ0EhMuaGNvcmUuU3RhcnRSZXF1ZXN0GhcuaGNvcmUuQ29yZUluZm9SZXNwb25zZRJBCg'
    '5TZWxlY3RPdXRib3VuZBIcLmhjb3JlLlNlbGVjdE91dGJvdW5kUmVxdWVzdBoRLmhjb21tb24u'
    'UmVzcG9uc2USMwoHVXJsVGVzdBIVLmhjb3JlLlVybFRlc3RSZXF1ZXN0GhEuaGNvbW1vbi5SZX'
    'Nwb25zZRIyCg1VcmxUZXN0QWN0aXZlEg4uaGNvbW1vbi5FbXB0eRoRLmhjb21tb24uUmVzcG9u'
    'c2USVQoSR2VuZXJhdGVXYXJwQ29uZmlnEiAuaGNvcmUuR2VuZXJhdGVXYXJwQ29uZmlnUmVxdW'
    'VzdBodLmhjb3JlLldhcnBHZW5lcmF0aW9uUmVzcG9uc2USQAoUR2V0U3lzdGVtUHJveHlTdGF0'
    'dXMSDi5oY29tbW9uLkVtcHR5GhguaGNvcmUuU3lzdGVtUHJveHlTdGF0dXMSTwoVU2V0U3lzdG'
    'VtUHJveHlFbmFibGVkEiMuaGNvcmUuU2V0U3lzdGVtUHJveHlFbmFibGVkUmVxdWVzdBoRLmhj'
    'b21tb24uUmVzcG9uc2USNQoLTG9nTGlzdGVuZXISES5oY29yZS5Mb2dSZXF1ZXN0GhEuaGNvcm'
    'UuTG9nTWVzc2FnZTABEiwKBUNsb3NlEhMuaGNvcmUuQ2xvc2VSZXF1ZXN0Gg4uaGNvbW1vbi5F'
    'bXB0eRIwCghHZXRMQU5JUBIOLmhjb21tb24uRW1wdHkaFC5oY29yZS5MQU5JUFJlc3BvbnNlEl'
    'MKEEdldEFkYXB0aXZlU3RhdGUSHi5oY29yZS5HZXRBZGFwdGl2ZVN0YXRlUmVxdWVzdBofLmhj'
    'b3JlLkdldEFkYXB0aXZlU3RhdGVSZXNwb25zZQ==');
