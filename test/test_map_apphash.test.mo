import Map "mo:core/Map";
import OrderLib "mo:core/Order";
import Principal "mo:core/Principal";
type Account = { owner : Principal; subaccount : ?Blob };
let apphash : ((?Nat, Account), (?Nat, Account)) -> OrderLib.Order = func(x,y) = #equal;
let map : Map.Map<(?Nat, Account), Nat> = Map.empty();
let key = (null, {owner=Principal.fromText("aaaaa-aa"); subaccount=null});
ignore Map.add<(?Nat, Account), Nat>(map, apphash, key, 1);
