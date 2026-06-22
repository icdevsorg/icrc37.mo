import ClassPlus "mo:class-plus";
import Types "service";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

module {
    public type Caller = Principal.Principal;
    
    // Core arguments and results matching ICRC-37 types
    public type ApproveTokensArgs = [Types.ApproveTokenArg];
    public type ApproveTokensResult = [?Types.ApproveTokenResult];
    
    public type ApproveCollectionArgs = [Types.ApproveCollectionArg];
    public type ApproveCollectionResult = [?Types.ApproveCollectionResult];
    
    public type TransferFromArgs = [Types.TransferFromArg];
    public type TransferFromResult = [?Types.TransferFromResult];

    public type RevokeTokenApprovalsArgs = [Types.RevokeTokenApprovalArg];
    public type RevokeTokenApprovalsResult = [?Types.RevokeTokenApprovalResult];

    public type RevokeCollectionApprovalsArgs = [Types.RevokeCollectionApprovalArg];
    public type RevokeCollectionApprovalsResult = [?Types.RevokeCollectionApprovalResult];

    public type IsApprovedArgs = [Types.IsApprovedArg];
    public type IsApprovedResult = [Bool];

    // Request Types
    public type Request = {
        #approve_tokens: ApproveTokensArgs;
        #approve_collection: ApproveCollectionArgs;
        #transfer_from: TransferFromArgs;
        #revoke_token_approvals: RevokeTokenApprovalsArgs;
        #revoke_collection_approvals: RevokeCollectionApprovalsArgs;
        #is_approved: IsApprovedArgs;
    };

    public type Response = {
        #approve_tokens: ApproveTokensResult;
        #approve_collection: ApproveCollectionResult;
        #transfer_from: TransferFromResult;
        #revoke_token_approvals: RevokeTokenApprovalsResult;
        #revoke_collection_approvals: RevokeCollectionApprovalsResult;
        #is_approved: IsApprovedResult;
    };

    public type GenericBatchError = { error_code : Nat; message : Text };

    // Standard handler types matching pattern
    public type BeforeHandler = (caller: Caller, request: Request) -> Result.Result<Request, GenericBatchError>;
    public type AfterHandler = (caller: Caller, request: Request, result: Response) -> Result.Result<Response, GenericBatchError>;

    public type Handlers = {
        beforeApproveTokens: ?BeforeHandler;
        afterApproveTokens: ?AfterHandler;

        beforeApproveCollection: ?BeforeHandler;
        afterApproveCollection: ?AfterHandler;

        beforeTransferFrom: ?BeforeHandler;
        afterTransferFrom: ?AfterHandler;

        beforeRevokeTokenApprovals: ?BeforeHandler;
        afterRevokeTokenApprovals: ?AfterHandler;

        beforeRevokeCollectionApprovals: ?BeforeHandler;
        afterRevokeCollectionApprovals: ?AfterHandler;

        beforeIsApproved: ?BeforeHandler;
        afterIsApproved: ?AfterHandler;
    };

    public type ExecutionHook<TArgs, TResult> = (caller: Caller, args: TArgs) -> Result.Result<TResult, GenericBatchError>;

    public let defaultHandlers: Handlers = {
        beforeApproveTokens = null;
        afterApproveTokens = null;
        beforeApproveCollection = null;
        afterApproveCollection = null;
        beforeTransferFrom = null;
        afterTransferFrom = null;
        beforeRevokeTokenApprovals = null;
        afterRevokeTokenApprovals = null;
        beforeRevokeCollectionApprovals = null;
        afterRevokeCollectionApprovals = null;
        beforeIsApproved = null;
        afterIsApproved = null;
    };

    public func execute<Req, Res, Out>(
        caller: Caller,
        request: Req,
        reqToTagged: (Req) -> Request,
        taggedToReq: (Request) -> Req,
        resToTagged: (Res) -> Response,
        taggedToRes: (Response) -> Res,
        beforeHandler: ?BeforeHandler,
        afterHandler: ?AfterHandler,
        coreExecute: ExecutionHook<Req, Res>,
        _createBatchError: (GenericBatchError) -> Out,
        resToOut: (Res) -> Out
    ): Result.Result<Out, GenericBatchError> {
        
        let initialReq = reqToTagged(request);
        
        // 1. Run before hook
        let handledReq = switch(beforeHandler) {
            case null request;
            case (?handler) {
                switch(handler(caller, initialReq)) {
                    case (#ok(validatedReq)) {
                        taggedToReq(validatedReq);
                    };
                    case (#err(e)) return #err(e);
                }
            }
        };
        let handledTaggedReq = reqToTagged(handledReq);

        // 2. Execute core logic
        let coreResult = switch(coreExecute(caller, handledReq)) {
            case (#ok(res)) res;
            case (#err(e)) return #err(e);
        };

        // 3. Run after hook
        let finalResult = switch(afterHandler) {
            case null coreResult;
            case (?handler) {
                let taggedResult = resToTagged(coreResult);
                switch(handler(caller, handledTaggedReq, taggedResult)) {
                    case (#ok(modifiedRes)) taggedToRes(modifiedRes);
                    case (#err(e)) return #err(e);
                }
            }
        };

        return #ok(resToOut(finalResult));
    };

    // Specific typed wrappers
    public func executeApproveTokens<Out>(caller: Caller, args: ApproveTokensArgs, handlers: Handlers, coreExecute: ExecutionHook<ApproveTokensArgs, ApproveTokensResult>, createErr: (GenericBatchError) -> Out, toOut: (ApproveTokensResult) -> Out) : Result.Result<Out, GenericBatchError> {
        execute<ApproveTokensArgs, ApproveTokensResult, Out>(
            caller, args,
            func(r){ #approve_tokens(r) },
            func(r){ switch(r) { case (#approve_tokens(req)) req; case (_) Debug.trap("Invalid request cast") } },
            func(r){ #approve_tokens(r) },
            func(r){ switch(r) { case (#approve_tokens(res)) res; case (_) Debug.trap("Invalid result cast") } },
            handlers.beforeApproveTokens,
            handlers.afterApproveTokens,
            coreExecute, createErr, toOut
        )
    };

    public func executeApproveCollection<Out>(caller: Caller, args: ApproveCollectionArgs, handlers: Handlers, coreExecute: ExecutionHook<ApproveCollectionArgs, ApproveCollectionResult>, createErr: (GenericBatchError) -> Out, toOut: (ApproveCollectionResult) -> Out) : Result.Result<Out, GenericBatchError> {
        execute<ApproveCollectionArgs, ApproveCollectionResult, Out>(
            caller, args,
            func(r){ #approve_collection(r) },
            func(r){ switch(r) { case (#approve_collection(req)) req; case (_) Debug.trap("Invalid request cast") } },
            func(r){ #approve_collection(r) },
            func(r){ switch(r) { case (#approve_collection(res)) res; case (_) Debug.trap("Invalid result cast") } },
            handlers.beforeApproveCollection,
            handlers.afterApproveCollection,
            coreExecute, createErr, toOut
        )
    };

    public func executeTransferFrom<Out>(caller: Caller, args: TransferFromArgs, handlers: Handlers, coreExecute: ExecutionHook<TransferFromArgs, TransferFromResult>, createErr: (GenericBatchError) -> Out, toOut: (TransferFromResult) -> Out) : Result.Result<Out, GenericBatchError> {
        execute<TransferFromArgs, TransferFromResult, Out>(
            caller, args,
            func(r){ #transfer_from(r) },
            func(r){ switch(r) { case (#transfer_from(req)) req; case (_) Debug.trap("Invalid request cast") } },
            func(r){ #transfer_from(r) },
            func(r){ switch(r) { case (#transfer_from(res)) res; case (_) Debug.trap("Invalid result cast") } },
            handlers.beforeTransferFrom,
            handlers.afterTransferFrom,
            coreExecute, createErr, toOut
        )
    };

    public func executeRevokeTokenApprovals<Out>(caller: Caller, args: RevokeTokenApprovalsArgs, handlers: Handlers, coreExecute: ExecutionHook<RevokeTokenApprovalsArgs, RevokeTokenApprovalsResult>, createErr: (GenericBatchError) -> Out, toOut: (RevokeTokenApprovalsResult) -> Out) : Result.Result<Out, GenericBatchError> {
        execute<RevokeTokenApprovalsArgs, RevokeTokenApprovalsResult, Out>(
            caller, args,
            func(r){ #revoke_token_approvals(r) },
            func(r){ switch(r) { case (#revoke_token_approvals(req)) req; case (_) Debug.trap("Invalid request cast") } },
            func(r){ #revoke_token_approvals(r) },
            func(r){ switch(r) { case (#revoke_token_approvals(res)) res; case (_) Debug.trap("Invalid result cast") } },
            handlers.beforeRevokeTokenApprovals,
            handlers.afterRevokeTokenApprovals,
            coreExecute, createErr, toOut
        )
    };

    public func executeRevokeCollectionApprovals<Out>(caller: Caller, args: RevokeCollectionApprovalsArgs, handlers: Handlers, coreExecute: ExecutionHook<RevokeCollectionApprovalsArgs, RevokeCollectionApprovalsResult>, createErr: (GenericBatchError) -> Out, toOut: (RevokeCollectionApprovalsResult) -> Out) : Result.Result<Out, GenericBatchError> {
        execute<RevokeCollectionApprovalsArgs, RevokeCollectionApprovalsResult, Out>(
            caller, args,
            func(r){ #revoke_collection_approvals(r) },
            func(r){ switch(r) { case (#revoke_collection_approvals(req)) req; case (_) Debug.trap("Invalid request cast") } },
            func(r){ #revoke_collection_approvals(r) },
            func(r){ switch(r) { case (#revoke_collection_approvals(res)) res; case (_) Debug.trap("Invalid result cast") } },
            handlers.beforeRevokeCollectionApprovals,
            handlers.afterRevokeCollectionApprovals,
            coreExecute, createErr, toOut
        )
    };

    public func executeIsApproved<Out>(caller: Caller, args: IsApprovedArgs, handlers: Handlers, coreExecute: ExecutionHook<IsApprovedArgs, IsApprovedResult>, createErr: (GenericBatchError) -> Out, toOut: (IsApprovedResult) -> Out) : Result.Result<Out, GenericBatchError> {
        execute<IsApprovedArgs, IsApprovedResult, Out>(
            caller, args,
            func(r){ #is_approved(r) },
            func(r){ switch(r) { case (#is_approved(req)) req; case (_) Debug.trap("Invalid request cast") } },
            func(r){ #is_approved(r) },
            func(r){ switch(r) { case (#is_approved(res)) res; case (_) Debug.trap("Invalid result cast") } },
            handlers.beforeIsApproved,
            handlers.afterIsApproved,
            coreExecute, createErr, toOut
        )
    };

};
