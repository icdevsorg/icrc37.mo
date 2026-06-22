import Interface "../src/Interface";
import Inspect "../src/Inspect";
import Service "../src/service";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import { test } "mo:test";

let caller = Principal.fromText("aaaaa-aa");
let spender : Service.Account = {
	owner = Principal.fromText("rrkah-fqaaa-aaaaa-aaaaq-cai");
	subaccount = ?Blob.fromArray(Array.tabulate<Nat8>(32, func(i) = Nat8.fromNat(i)));
};

let validApproveArgs : Interface.ApproveTokensArgs = [
	{
		token_id = 1;
		approval_info = {
			from_subaccount = null;
			spender = spender;
			memo = null;
			expires_at = null;
			created_at_time = null;
		};
	}
];

test(
	"Interface.executeApproveTokens runs before and after hooks",
	func() {
		var beforeCalled = false;
		var afterCalled = false;

		let handlers : Interface.Handlers = {
			Interface.defaultHandlers with
			beforeApproveTokens = ?(func(_caller, request) {
				beforeCalled := true;
				#ok(request);
			});
			afterApproveTokens = ?(func(_caller, _request, result) {
				afterCalled := true;
				#ok(result);
			});
		};

		type Out = {
			#ok : Interface.ApproveTokensResult;
			#err : Interface.GenericBatchError;
		};

		let executed = Interface.executeApproveTokens<Out>(
			caller,
			validApproveArgs,
			handlers,
			func(_caller, _args) {
				#ok([?#Ok(7)]);
			},
			func(err) { #err(err) },
			func(res) { #ok(res) },
		);

		assert(beforeCalled);
		assert(afterCalled);
		switch (executed) {
			case (#ok(#ok(result))) {
				assert(result.size() == 1);
			};
			case (_) assert(false);
		};
	},
);

test(
	"Interface.executeApproveTokens propagates before-hook errors",
	func() {
		let handlers : Interface.Handlers = {
			Interface.defaultHandlers with
			beforeApproveTokens = ?(func(_caller, _request) {
				#err({ error_code = 13; message = "blocked" });
			});
		};

		type Out = {
			#ok : Interface.ApproveTokensResult;
			#err : Interface.GenericBatchError;
		};

		let executed = Interface.executeApproveTokens<Out>(
			caller,
			validApproveArgs,
			handlers,
			func(_caller, _args) { #ok([?#Ok(7)]) },
			func(err) { #err(err) },
			func(res) { #ok(res) },
		);

		switch (executed) {
			case (#err(err)) {
				assert(err.error_code == 13);
				assert(err.message == "blocked");
			};
			case (_) assert(false);
		};
	},
);

test(
	"Interface.executeApproveTokens threads mutated request into core and after hooks",
	func() {
		var afterSawMutatedRequest = false;
		let rewrittenSpender : Service.Account = {
			owner = Principal.fromText("be2us-64aaa-aaaaa-qaabq-cai");
			subaccount = null;
		};

		let handlers : Interface.Handlers = {
			Interface.defaultHandlers with
			beforeApproveTokens = ?(func(_caller, request) {
				switch (request) {
					case (#approve_tokens(args)) {
						#ok(#approve_tokens([
							{
								token_id = args[0].token_id;
								approval_info = {
									from_subaccount = args[0].approval_info.from_subaccount;
									spender = rewrittenSpender;
									memo = args[0].approval_info.memo;
									expires_at = args[0].approval_info.expires_at;
									created_at_time = args[0].approval_info.created_at_time;
								};
							}
						]));
					};
					case (_) #err({ error_code = 99; message = "unexpected request" });
				};
			});
			afterApproveTokens = ?(func(_caller, request, result) {
				switch (request) {
					case (#approve_tokens(args)) {
						afterSawMutatedRequest := args[0].approval_info.spender.owner == rewrittenSpender.owner;
					};
					case (_) assert(false);
				};
				#ok(result);
			});
		};

		type Out = {
			#ok : Interface.ApproveTokensResult;
			#err : Interface.GenericBatchError;
		};

		let executed = Interface.executeApproveTokens<Out>(
			caller,
			validApproveArgs,
			handlers,
			func(_caller, args) {
				assert(args[0].approval_info.spender.owner == rewrittenSpender.owner);
				#ok([?#Ok(9)]);
			},
			func(err) { #err(err) },
			func(res) { #ok(res) },
		);

		assert(afterSawMutatedRequest);
		switch (executed) {
			case (#ok(#ok(result))) {
				assert(result.size() == 1);
			};
			case (_) assert(false);
		};
	},
);

test(
	"Inspect rejects oversize memo and invalid subaccount",
	func() {
		let badAccount : Service.Account = {
			owner = spender.owner;
			subaccount = ?Blob.fromArray([1, 2, 3]);
		};
		let badArgs : [Service.ApproveTokenArg] = [
			{
				token_id = 1;
				approval_info = {
					from_subaccount = ?Blob.fromArray([9]);
					spender = badAccount;
					memo = ?Blob.fromArray(Array.tabulate<Nat8>(257, func(_i) = 1));
					expires_at = null;
					created_at_time = null;
				};
			}
		];

		assert(not Inspect.inspectApproveTokens(badArgs, null));
	},
);
