import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_investment_stat_definition.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_stat.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/item_stats/base_item_stat.widget.dart';

class BaseItemStatsWidget extends BaseDestinyStatefulItemWidget {
  final Map<int, int> selectedPerks;

  BaseItemStatsWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      Key key,
      this.selectedPerks})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key);

  @override
  BaseDestinyItemState<BaseDestinyStatefulItemWidget> createState() {
    return BaseItemStatsState();
  }
}

class BaseItemStatsState<T extends BaseItemStatsWidget>
    extends BaseDestinyItemState<T> {
  Map<int, DestinyInventoryItemDefinition> plugDefinitions;
  Map<String, DestinyStat> precalculatedStats;
  List<DestinyItemSocketState> socketStates;

  DestinyStatGroupDefinition statGroupDefinition;

  @override
  void initState() {
    this.precalculatedStats =
        widget.profile.getPrecalculatedStats(item.itemInstanceId);
    this.socketStates = widget.profile.getItemSockets(item.itemInstanceId);
    super.initState();
    this.loadPlugDefinitions();
    this.loadStatGroupDefinition();
  }

  Future<void> loadPlugDefinitions() async {
    List<int> plugHashes = definition.sockets.socketEntries
        .expand((socket) {
          List<int> hashes = [];
          if ((socket.singleInitialItemHash ?? 0) != 0) {
            hashes.add(socket.singleInitialItemHash);
          }
          if ((socket.reusablePlugItems?.length ?? 0) != 0) {
            hashes.addAll(socket.reusablePlugItems
                .map((plugItem) => plugItem.plugItemHash));
          }
          if ((socket.randomizedPlugItems?.length ?? 0) != 0) {
            hashes.addAll(socket.randomizedPlugItems
                .map((plugItem) => plugItem.plugItemHash));
          }
          return hashes;
        })
        .where((i) => i != null)
        .toList();
    if (socketStates != null) {
      Iterable<int> hashes = socketStates
          .map((state) => state.plugHash)
          .where((i) => i != null)
          .toList();
      plugHashes.addAll(hashes);
    }
    plugDefinitions = await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    if (mounted) {
      setState(() {});
    }
  }

  Future loadStatGroupDefinition() async {
    if (definition?.stats?.statGroupHash != null) {
      statGroupDefinition = await widget.manifest
          .getDefinition<DestinyStatGroupDefinition>(
              definition?.stats?.statGroupHash);
      if (mounted) {
        setState(() {});
      }
    }
    print(statGroupDefinition);
  }

  @override
  Widget build(BuildContext context) {    
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          buildHeader(context),
          Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(children: buildStats(context))),
        ],
      ),
    );
  }

  buildHeader(BuildContext context) {
    return HeaderWidget(
        child: Container(
      alignment: Alignment.centerLeft,
      child: Row(children: [
        Expanded(child:Text(
          "Name",
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        Expanded(child:Text(
          "Pre",
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        Expanded(child:Text(
          "calculated",
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        Expanded(child:Text(
          "masterwork",
          style: TextStyle(fontWeight: FontWeight.bold),
        ))
      ]),
    ));
  }

  buildStats(context) {
    Map<int, StatValues> statValues = getStatValues();

    return statValues.entries.map((entry) {
      var stat = entry.value;
      return BaseItemStatWidget(entry.key, stat, scaled: statGroupDefinition.scaledStats.firstWhere((s)=>s.statHash == entry.key, orElse:()=>null),);
    }).toList();
  }

  Map<int, StatValues> getStatValues() {
    Map<int, StatValues> map = new Map();
    if (plugDefinitions == null) {
      return map;
    }
    stats.forEach((s) {
      var pre = precalculatedStats.containsKey("${s.statTypeHash}")
          ? precalculatedStats["${s.statTypeHash}"].value
          : 0;
      map[s.statTypeHash] = new StatValues(

          equipped: s.value, selected: s.value, precalculated: pre);
    });

    List<int> plugHashes;
    if (socketStates != null) {
      plugHashes = socketStates.map((state) => state.plugHash).toList();
    } else {
      plugHashes = definition.sockets.socketEntries
          .map((plug) => plug.singleInitialItemHash)
          .toList();
    }

    plugHashes.forEach((plugHash) {
      int index = plugHashes.indexOf(plugHash);
      DestinyInventoryItemDefinition def = plugDefinitions[plugHash];
      var state;
      if (socketStates != null) {
        state = socketStates[index];
      }
      if (def == null) {
        return;
      }
      var selectedPlugHash = widget?.selectedPerks != null
          ? widget.selectedPerks[index]
          : plugHash;
      DestinyInventoryItemDefinition selectedDef =
          plugDefinitions[selectedPlugHash];
      def?.investmentStats?.forEach((stat) {
        StatValues values = map[stat.statTypeHash] ?? new StatValues();
        if (def.plug?.uiPlugLabel == 'masterwork' &&
            (state?.reusablePlugHashes?.length ?? 0) == 0) {
          values.masterwork += stat.value;
        } else {
          values.equipped += stat.value;
          if (selectedDef == null) {
            values.selected += stat.value;
          }
        }
        map[stat.statTypeHash] = values;
      });

      if (selectedDef != null) {
        selectedDef.investmentStats.forEach((stat) {
          StatValues values = map[stat.statTypeHash] ?? new StatValues();
          if (selectedDef.plug?.uiPlugLabel != 'masterwork') {
            values.selected += stat.value;
          }
          map[stat.statTypeHash] = values;
        });
      }
    });

    return map;
  }

  Iterable<DestinyItemInvestmentStatDefinition> get stats {
    if (statGroupDefinition?.scaledStats == null) {
      return null;
    }
    var statWhitelist =
        statGroupDefinition.scaledStats.map((s) => s.statHash).toList();
    var noBarStats = statGroupDefinition.scaledStats
        .where((s) => s.displayAsNumeric)
        .map((s) => s.statHash)
        .toList();
    statWhitelist.addAll(DestinyData.hiddenStats);
    List<DestinyItemInvestmentStatDefinition> stats = definition.investmentStats
        .where((stat) => statWhitelist.contains(stat.statTypeHash))
        .toList();

    for (var stat in statGroupDefinition?.scaledStats) {
      if (statWhitelist.contains(stat.statHash) &&
          stats.where((s) => s.statTypeHash == stat.statHash).length == 0) {
        var newStat = DestinyItemInvestmentStatDefinition()
          ..statTypeHash = stat.statHash
          ..value = 0
          ..isConditionallyActive = false;
        stats.add(newStat);
      }
    }

    stats.sort((statA, statB) {
      int valA = noBarStats.contains(statA.statTypeHash)
          ? 2
          : DestinyData.hiddenStats.contains(statA.statTypeHash) ? 1 : 0;
      int valB = noBarStats.contains(statB.statTypeHash)
          ? 2
          : DestinyData.hiddenStats.contains(statB.statTypeHash) ? 1 : 0;
      return valA - valB;
    });
    return stats;
  }
}
