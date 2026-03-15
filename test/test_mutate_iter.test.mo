import Map "mo:core/Map";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import D "mo:base/Debug";

let map = Map.empty<Nat, Nat>();
ignore Map.add(map, Nat.compare, 0, 0);
ignore Map.add(map, Nat.compare, 1, 1);
ignore Map.add(map, Nat.compare, 2, 2);
ignore Map.add(map, Nat.compare, 3, 3);
ignore Map.add(map, Nat.compare, 4, 4);

let entries = Map.entries(map);
for((k, v) in entries){
    D.print("k=" # debug_show(k));
    ignore Map.remove(map, Nat.compare, k);
};
D.print("rest:");
for((k, v) in Map.entries(map)){
    D.print("k=" # debug_show(k));
};

