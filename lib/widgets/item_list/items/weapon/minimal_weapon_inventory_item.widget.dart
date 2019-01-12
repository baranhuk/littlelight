import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/definition_table_names.enum.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_info_label.mixin.dart';

class MinimalWeaponInventoryItemWidget extends MinimalBaseInventoryItemWidget
    with MinimalInfoLabelMixin {
  MinimalWeaponInventoryItemWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition itemDefinition,
      DestinyItemInstanceComponent instanceInfo,
      {@required String characterId, Key key})
      : super(item, itemDefinition, instanceInfo, characterId:characterId, key:key);
      
  double get valueFontSize => 12;
  
  @override
  Widget primaryStatWidget(BuildContext context) {
    return infoContainer(context, weaponPrimaryStat(context));
  }

  Widget weaponPrimaryStat(BuildContext context) {
    Color damageTypeColor = DestinyData.getDamageTypeTextColor(damageType);
    return 
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              primaryStatIcon(context, DestinyData.getAmmoTypeIcon(ammoType),
                  DestinyData.getAmmoTypeColor(ammoType),
                  size: 15),
              primaryStatValueField(context, damageTypeColor),
            ].where((w) => w != null).toList()
    );
  }

  Widget primaryStatValueField(BuildContext context, Color color) {
    return Text(
      "${primaryStat.value}",
      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: valueFontSize),
    );
  }

  Widget primaryStatNameField(BuildContext context, Color color) {
    return ManifestText(DefinitionTableNames.destinyStatDefinition,
        primaryStat.statHash,
        uppercase: true,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w300, fontSize: 16));
  }

  Widget primaryStatIcon(BuildContext context, IconData icon, Color color,
      {double size = 22}) {
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }


  int get ammoType => definition.equippingBlock.ammoType;
  
  int get damageType => instanceInfo.damageType;

  get primaryStat => instanceInfo.primaryStat;
}