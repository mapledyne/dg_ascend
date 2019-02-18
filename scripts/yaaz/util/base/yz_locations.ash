import "util/base/yz_util.ash";
import "util/base/yz_quests.ash";
import "util/base/yz_print.ash";
import "util/base/yz_settings.ash";
import "util/base/yz_inventory.ash";

boolean open_location(location loc);
location pick_semi_rare_location();

boolean location_open(location l)
{
  switch (l)
  {
    case $location[the spooky forest]:
      return quest_status("questL02Larva") >= STARTED;
    case $location[the old landfill]:
      return (quest_status("questM19Hippy") != UNSTARTED);
    case $location[madness bakery]:
      return (quest_status("questM25Armory") != UNSTARTED);
    case $location[the overgrown lot]:
      if (quest_status("questM24Doc") != UNSTARTED)
        return true;
      if (setting("overgrown_lot") == "true")
        return true;
      string lot = visit_url("place.php?whichplace=town_wrong");
      if (contains_text(lot, "The Overgrown Lot"))
      {
        save_daily_setting("overgrown_lot", "true");
        return true;
      } else {
        return open_location(l);
      }
    case $location[the "fun" house]:
      return quest_status("questG04Nemesis") >= 5;
    case $location[a barroom brawl]:
      return quest_status("questL03Rat") >= 1;
    case $location[the beanbat chamber]:
      return quest_status("questL04Bat") >= 1;
    case $location[south of the border]:
      return prop_int("lastDesertUnlock") >= my_ascensions();
    case $location[cobb's knob harem]:
    case $location[cobb's knob treasury]:
    case $location[cobb's knob kitchens]:
    case $location[Cobb's Knob Barracks]:
      return quest_status("questL05Goblin") >= 1;
    case $location[cobb's knob laboratory]:
      return item_amount($item[cobb's knob lab key]) > 0;
    case $location[Cobb's Knob Menagerie, Level 1]:
    case $location[Cobb's Knob Menagerie, Level 2]:
    case $location[Cobb's Knob Menagerie, Level 3]:
      return item_amount($item[Cobb's Knob Menagerie key]) > 0;
    case $location[the degrassi knoll restroom]:
    case $location[the degrassi knoll gym]:
      return !knoll_available();
    case $location[8-bit realm]:
      return have($item[continuum transfunctioner]);
    case $location[the haunted kitchen]:
    case $location[the haunted conservatory]:
      return quest_status("questM20Necklace") != UNSTARTED;
    case $location[the haunted billiards room]:
      return have($item[Spookyraven billiards room key]);
    case $location[the haunted library]:
      return have($item[[7302]Spookyraven library key]);
    case $location[the haunted bathroom]:
    case $location[the haunted bedroom]:
    case $location[the haunted gallery]:
      return quest_status("questM21Dance") >= 1;
    case $location[the haunted ballroom]:
      return quest_status("questM21Dance") >= 3;
    case $location[the haunted storage room]:
    case $location[the haunted laboratory]:
    case $location[the haunted nursery]:
      return quest_status("questM17Babies") != UNSTARTED;
    case $location[the haunted wine cellar]:
    case $location[the haunted boiler room]:
    case $location[the haunted laundry room]:
      return quest_status("questL11Manor") >= 1;
    case $location[the hidden office building]:
      return prop_int("hiddenOfficeProgress") > 0;
    case $location[lair of the ninja snowmen]:
      return quest_status("questL08Trapper") >= 2;
    default:
      debug("Checking location_open(" + wrap(l) + ") and returning the default: " + wrap('true', COLOR_LOCATION));
      return true;
  }
}


boolean can_access_sea()
{
  switch (my_path())
  {
    case "":
    case "None":
    case "Standard":
    case "Teetotaler":
    case "Boozetafarian":
    case "Oxygenarian":
    case "Bees Hate You":
    case "Trendy":
    case "Pocket Familiars":
    case "Live. Ascend. Repeat.":
    case "License to Adventure":
    case "Nuclear Autumn":
    case "Avatar of West of Loathing":
    case "One Crazy Random Summer":
    case "Picky":
    case "Heavy Rains":
    case "Slow and Steady":
    case "Class Act":
    case "BIG!":
    case "Bugbear Invasion":
      return true;
  }
  return false;

}

location pick_semi_rare_location()
{
  location last = to_location(get_property("semirareLocation"));

  boolean maybe_pool = !to_boolean(setting("aggressive_optimize", "false"));
  maybe_pool = to_boolean(setting("pool_skill", maybe_pool));
  int shark_visits = prop_int("poolSharkCount");

  if (last != $location[the haunted billiards room]
      && maybe_pool
      && have($item[Spookyraven billiards room key])
      && shark_visits < 25)
  {
    set_property("choiceAdventure330", 1);
    return $location[the haunted billiards room];
  }
  if (shark_visits >= 25)
  {
    // switch to the fight once we have enough pool skill.
    // this script won't auto-choose it at this point, but polite to change it
    // if the other option isn't needed anymore.
    set_property("choiceAdventure330", 2);
  }

  if (quest_status("questL10Garbage") >= 9
      && to_boolean(setting("war_nuns", "false"))
      && get_property("sidequestNunsCompleted") == "none"
      && last != $location[The Castle in the Clouds in the Sky (Top Floor)])
  {
    return $location[The Castle in the Clouds in the Sky (Top Floor)];
  }

  // if we don't have the KGE outfit, get it for dispensary access.
  if (!have_outfit("Knob Goblin Elite Guard Uniform")
      && last != $location[Cobb's Knob Barracks]
      && location_open($location[Cobb's Knob Barracks]))
  {
    return $location[Cobb's Knob Barracks];
  }

  // Get some stone wool if useful:
  if (!hidden_temple_unlocked() && item_amount($item[stone wool]) < 2)
  {
    if (quest_status("questL11Worship") < 3)
      return $location[The Hidden Temple];
  }

  if (last == $location[the haunted pantry])
  {
    return $location[the sleazy back alley];
  }
  return $location[the haunted pantry];
}




boolean open_location(location loc)
{
  switch(loc)
  {
    default:
      log("I don't yet know how to open " + wrap(loc) + ".");
      wait(10);
      return false;
    case $location[the overgrown lot]:
      return start_galaktik();
    case $location[madness bakery]:
      return start_bakery();
  }

}
