import 'package:bungie_api/enums/destiny_item_sub_type.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/utils/item_sorters/base_item_sorter.dart';

List<DestinyItemSubType> _subtypeOrder = [
  DestinyItemSubType.HandCannon,
  DestinyItemSubType.AutoRifle,
  DestinyItemSubType.PulseRifle,
  DestinyItemSubType.ScoutRifle,
  DestinyItemSubType.Sidearm,
  DestinyItemSubType.SubmachineGun,
  DestinyItemSubType.TraceRifle,
  DestinyItemSubType.Bow,
  DestinyItemSubType.Shotgun,
  DestinyItemSubType.SniperRifle,
  DestinyItemSubType.FusionRifle,
  DestinyItemSubType.FusionRifleLine,
  DestinyItemSubType.GrenadeLauncher,
  DestinyItemSubType.RocketLauncher,
  DestinyItemSubType.Sword,
  DestinyItemSubType.Machinegun,
  DestinyItemSubType.HelmetArmor,
  DestinyItemSubType.GauntletsArmor,
  DestinyItemSubType.ChestArmor,
  DestinyItemSubType.LegArmor,
  DestinyItemSubType.ClassArmor,
  DestinyItemSubType.Shader,
  DestinyItemSubType.Ornament,
  DestinyItemSubType.Mask,
  DestinyItemSubType.Crm,
];

class SubTypeSorter extends BaseItemSorter {
  SubTypeSorter(int direction) : super(direction);

  @override
  int sort(ItemWithOwner itemA, ItemWithOwner itemB) {
    DestinyItemSubType subTypeA = def(itemA)?.itemSubType;
    DestinyItemSubType subTypeB = def(itemB)?.itemSubType;
    int orderA = _subtypeOrder.indexOf(subTypeA);
    int orderB = _subtypeOrder.indexOf(subTypeB);
    return direction * orderA.compareTo(orderB);
  }
}
