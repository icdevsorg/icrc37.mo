import ICRC37 ".";

mixin(
  config: ICRC37.MixinFunctionArgs
) {

  transient let icrc37 = ICRC37.Init({
    org_icdevs_class_plus_manager = config.org_icdevs_class_plus_manager;
    initialState = switch (config.initialState) {
      case (?state) state;
      case (null) ICRC37.initialState();
    };
    args = config.args;
    pullEnvironment = config.pullEnvironment;
    onInitialize = config.onInitialize;
    onStorageChange = switch (config.onStorageChange) {
      case (?handler) handler;
      case (null) func(_state : ICRC37.State) {};
    };
  });

  public query func icrc37_metadata() : async ICRC37.Service.MetadataResponse {
    icrc37().metadata();
  };

  public query func icrc37_max_approvals_per_token_or_collection() : async ?Nat {
    icrc37().max_approvals_per_token_or_collection();
  };

  public query func icrc37_max_revoke_approvals() : async ?Nat {
    ?icrc37().get_ledger_info().max_revoke_approvals;
  };

  public shared query ({caller}) func icrc37_is_approved(args : [ICRC37.Service.IsApprovedArg]) : async [Bool] {
    icrc37().is_approved_with_caller(caller, args);
  };

  public query func icrc37_get_token_approvals(token_ids : [Nat], prev : ?ICRC37.Service.TokenApproval, take : ?Nat) : async [ICRC37.Service.TokenApproval] {
    icrc37().get_token_approvals(token_ids, prev, take);
  };

  public query func icrc37_get_collection_approvals(owner : ICRC37.Account, prev : ?ICRC37.Service.CollectionApproval, take : ?Nat) : async [ICRC37.Service.CollectionApproval] {
    icrc37().get_collection_approvals(owner, prev, take);
  };

  public shared ({caller}) func icrc37_approve_tokens(args : [ICRC37.Service.ApproveTokenArg]) : async [?ICRC37.Service.ApproveTokenResult] {
    icrc37().approve_tokens<system>(caller, args);
  };

  public shared ({caller}) func icrc37_approve_collection(args : [ICRC37.Service.ApproveCollectionArg]) : async [?ICRC37.Service.ApproveCollectionResult] {
    icrc37().approve_collection<system>(caller, args);
  };

  public shared ({caller}) func icrc37_transfer_from<system>(args : [ICRC37.Service.TransferFromArg]) : async [?ICRC37.Service.TransferFromResult] {
    icrc37().transfer_from<system>(caller, args);
  };

  public shared ({caller}) func icrc37_revoke_token_approvals<system>(args : [ICRC37.Service.RevokeTokenApprovalArg]) : async [?ICRC37.Service.RevokeTokenApprovalResult] {
    icrc37().revoke_token_approvals<system>(caller, args);
  };

  public shared ({caller}) func icrc37_revoke_collection_approvals<system>(args : [ICRC37.Service.RevokeCollectionApprovalArg]) : async [?ICRC37.Service.RevokeCollectionApprovalResult] {
    icrc37().revoke_collection_approvals<system>(caller, args);
  };
};