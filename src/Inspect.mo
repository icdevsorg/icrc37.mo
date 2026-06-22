/// ICRC37/Inspect.mo - Message inspection helpers
import Blob "mo:core/Blob";
import Runtime "mo:core/Runtime";
import Nat "mo:core/Nat";
import ICRC37Type "service";

module {
  public type Config = {
    maxMemoSize : Nat;
    maxSubaccountSize : Nat;
    maxBatchSize : Nat;
    maxRawArgSize : Nat;
  };

  public let defaultConfig : Config = {
    maxMemoSize = 256;
    maxSubaccountSize = 32;
    maxBatchSize = 1000;
    maxRawArgSize = 100000;
  };

  public func isValidMemo(memo : ?Blob, config : Config) : Bool {
    switch (memo) {
      case (null) true;
      case (?m) m.size() <= config.maxMemoSize;
    };
  };

  public func isValidSubaccount(sub : ?Blob, config : Config) : Bool {
    switch (sub) {
      case (null) true;
      case (?s) s.size() == config.maxSubaccountSize;
    };
  };

  public func isValidAccount(account : ICRC37Type.Account, config : Config) : Bool {
    isValidSubaccount(account.subaccount, config);
  };
  
  public func isValidApprovalInfo(info : ICRC37Type.ApprovalInfo, config : Config) : Bool {
    if (not isValidSubaccount(info.from_subaccount, config)) return false;
    if (not isValidAccount(info.spender, config)) return false;
    if (not isValidMemo(info.memo, config)) return false;
    true
  };

  public func inspectTransferFrom(args : [ICRC37Type.TransferFromArg], config : ?Config) : Bool {
    let cfg = switch (config) { case (?c) c; case (null) defaultConfig };
    if (args.size() > cfg.maxBatchSize) return false;
    for (arg in args.vals()) {
      if (not isValidSubaccount(arg.spender_subaccount, cfg)) return false;
      if (not isValidAccount(arg.from, cfg)) return false;
      if (not isValidAccount(arg.to, cfg)) return false;
      if (not isValidMemo(arg.memo, cfg)) return false;
    };
    true
  };

  public func inspectApproveTokens(args : [ICRC37Type.ApproveTokenArg], config : ?Config) : Bool {
    let cfg = switch (config) { case (?c) c; case (null) defaultConfig };
    if (args.size() > cfg.maxBatchSize) return false;
    for (arg in args.vals()) {
      if (not isValidApprovalInfo(arg.approval_info, cfg)) return false;
    };
    true
  };

  public func inspectApproveCollection(args : [ICRC37Type.ApproveCollectionArg], config : ?Config) : Bool {
    let cfg = switch (config) { case (?c) c; case (null) defaultConfig };
    if (args.size() > cfg.maxBatchSize) return false;
    for (arg in args.vals()) {
      if (not isValidApprovalInfo(arg.approval_info, cfg)) return false;
    };
    true
  };

  public func inspectRevokeTokenApprovals(args : [ICRC37Type.RevokeTokenApprovalArg], config: ?Config) : Bool {
    let cfg = switch (config) { case (?c) c; case (null) defaultConfig };
    if (args.size() > cfg.maxBatchSize) return false;
    for (arg in args.vals()) {
      if (not isValidSubaccount(arg.from_subaccount, cfg)) return false;
      if (not isValidMemo(arg.memo, cfg)) return false;
      switch(arg.spender){
        case(?acct) { if (not isValidAccount(acct, cfg)) return false; };
        case(_) {};
      };
    };
    true
  };

  public func inspectRevokeCollectionApprovals(args : [ICRC37Type.RevokeCollectionApprovalArg], config: ?Config) : Bool {
    let cfg = switch (config) { case (?c) c; case (null) defaultConfig };
    if (args.size() > cfg.maxBatchSize) return false;
    for (arg in args.vals()) {
      if (not isValidSubaccount(arg.from_subaccount, cfg)) return false;
      if (not isValidMemo(arg.memo, cfg)) return false;
      switch(arg.spender){
        case(?acct) { if (not isValidAccount(acct, cfg)) return false; };
        case(_) {};
      };
    };
    true
  };

  public func inspectIsApproved(args : [ICRC37Type.IsApprovedArg], config: ?Config) : Bool {
    let cfg = switch (config) { case (?c) c; case (null) defaultConfig };
    if (args.size() > cfg.maxBatchSize) return false;
    for (arg in args.vals()) {
      if (not isValidAccount(arg.spender, cfg)) return false;
      if (not isValidSubaccount(arg.from_subaccount, cfg)) return false;
    };
    true
  };
  
  public func inspectGetTokenApprovals(token_ids : [Nat], config: ?Config) : Bool {
    let cfg = switch (config) { case (?c) c; case (null) defaultConfig };
    if (token_ids.size() > cfg.maxBatchSize) return false;
    true
  };

  public func guardTransferFrom(args: [ICRC37Type.TransferFromArg], config: ?Config) {
    if (not inspectTransferFrom(args, config)) {
      Runtime.trap("TransferFrom arguments exceed dimensional limits. Potential cycle drain blocked.");
    };
  };

  public func guardApproveTokens(args: [ICRC37Type.ApproveTokenArg], config: ?Config) {
    if (not inspectApproveTokens(args, config)) {
      Runtime.trap("ApproveTokens arguments exceed dimensional limits. Potential cycle drain blocked.");
    };
  };

  public func guardApproveCollection(args: [ICRC37Type.ApproveCollectionArg], config: ?Config) {
    if (not inspectApproveCollection(args, config)) {
      Runtime.trap("ApproveCollection arguments exceed dimensional limits. Potential cycle drain blocked.");
    };
  };

  public func guardRevokeTokenApprovals(args: [ICRC37Type.RevokeTokenApprovalArg], config: ?Config) {
    if (not inspectRevokeTokenApprovals(args, config)) {
      Runtime.trap("RevokeTokenApprovals arguments exceed dimensional limits.");
    };
  };

  public func guardRevokeCollectionApprovals(args: [ICRC37Type.RevokeCollectionApprovalArg], config: ?Config) {
    if (not inspectRevokeCollectionApprovals(args, config)) {
      Runtime.trap("RevokeCollectionApprovals arguments exceed dimensional limits.");
    };
  };

  public func guardIsApproved(args: [ICRC37Type.IsApprovedArg], config: ?Config) {
    if (not inspectIsApproved(args, config)) {
      Runtime.trap("IsApproved arguments exceed dimensional limits.");
    };
  };
  
  public func guardGetTokenApprovals(token_ids : [Nat], config: ?Config) {
    if (not inspectGetTokenApprovals(token_ids, config)) {
      Runtime.trap("GetTokenApprovals arguments exceed dimensional limits.");
    };
  };

}
