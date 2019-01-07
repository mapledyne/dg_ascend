import "util/base/yz_inventory.ash";
import "util/base/yz_monsters.ash";
import "special/locations/yz_terminal.ash";
import "util/base/yz_monsters.ash";
import "util/base/yz_war_support.ash";
import "util/base/yz_quests.ash";

boolean attracted(monster foe)
{
  monster digitized = to_monster(get_property("_sourceTerminalDigitizeMonster"));
  int copiesmade = to_int(get_property("_sourceTerminalDigitizeMonsterCount"));
  if (digitized == foe && copiesmade <= 2) return true;
  if (to_monster(get_property("enamorangMonster")) == foe) return true;
  if (to_monster(get_property("_latteMonster")) == foe) return true;

  return false;
}

string attract_action(monster foe)
{
  if (have_skill($skill[digitize])
      && digitize_remaining() > 0)
  {
    return "skill digitize";
  }

  if (have_skill($skill[offer latte to Opponent]))
  {
    return "skill offer latte to opponent";
  }

  if (have($item[LOV Enamorang])
      && get_property("enamorangMonster") == "")
  {
    return "item LOV enamorang";
  }
  if (have_skill($skill[Transcendent Olfaction])
      && have_effect($effect[on the trail]) == 0
      && my_mp() > mp_cost($skill[Transcendent Olfaction]))
  {
    return "skill Transcendent Olfaction";
  }

  return "";
}

string maybe_attract(monster foe)
{
  if (foe == $monster[none]) return "";

  string action = attract_action(foe);

  if (action == "") return "";

  if (attracted(foe)) return "";

  monster newyoumon = to_monster(get_property("_newYouQuestMonster"));
  if (get_property("_newYouQuestCompleted") != "false") newyoumon = $monster[none];

  if (is_bounty_monster(foe)) return action;

  if (newyoumon == foe) return action;
  if (monster_attract contains foe) return action;

  return "";
}

string maybe_duplicate(monster foe)
{
  if (!have_skill($skill[duplicate])) return "";
  int dupes = to_int(get_property("_sourceTerminalDuplicateUses"));
  int max_dupes = 1;
  if (my_path() == "The Source") max_dupes = 5;

  if (dupes >= max_dupes) return "";

  // bail if the monster is likely to kill us.
  if (expected_damage(foe) > my_hp() / 2) return "";

  switch (foe)
  {
    default:
      return "";
    case $monster[gaudy pirate]:
      if (have($item[Talisman o' Namsilat])) return "";
      if (have($item[snakehead charrrm])) return "";
      break;
  }

  return "skill duplicate";
}

string maybe_extract(monster foe)
{
  if (have_skill($skill[extract jelly]))
  {
    if (foe.attack_element != $element[none])
      return "skill extract jelly";
  }
  return "";
}

string maybe_shadow(monster foe)
{
  // this could obviously use some much better finesse.
  if (foe != $monster[your shadow]) return "";

  if (have_skill($skill[Ambidextrous Funkslinging]))
  {
    item healing1 = $item[gauze garter];
    item healing2 = $item[gauze garter];

    if (item_amount($item[gauze garter]) < 2) healing2 = $item[filthy poultice];
    if (item_amount($item[gauze garter]) < 1) healing1 = $item[filthy poultice];

    return "item " + healing1 + ", " + healing2;
  }
  abort("Combat with Your Shadow without the skill Ambidextrous Funkslinging isn't yet supported. Handle this battle yourself.");
  return "";
}

string maybe_yellow_ray(monster foe)
{
  if (have_effect($effect[everything looks yellow]) > 0) return "";

  item yr = yellow_ray_item();
  if (yr == $item[none]) return "";

  switch (foe)
  {
    default:
      return "";
    case $monster[frat warrior drill sergeant]:
    case $monster[war pledge]:
    case $monster[War Frat 151st Infantryman]:
      if (war_side() != "fratboy") return "";
      if (have_outfit(war_outfit())) return "";
      break;
    case $monster[war hippy drill sergeant]:
    case $monster[war hippy (space) cadet]:
      if (war_side() != "hippy") return "";
      if (have_outfit(war_outfit())) return "";
      break;
  }
  return "item " + yr;
}

string maybe_banish(monster foe)
{
// $skill[breath out]

  string banish = "";
  if (have_skill($skill[breathe out]))
  {
    banish = "skill breathe out";
  }
  else if (have_skill($skill[snokebomb]) && my_mp() > mp_cost($skill[snokebomb]))
  {
    banish = "skill snokebomb";
  }
  else if (have($item[tennis ball]))
  {
    banish = "item tennis ball";
  }
  else if (have_skill($skill[throw latte on opponent]))
  {
    banish = "skill throw latte on opponent";
  }
  else if (have_skill($skill[Macrometeorite]))
  {
    // not exactly a banish, but similar.
    banish = "skill Macrometeorite";
  }

  if (banish == "") return "";

  switch (foe)
  {
    default:
      return "";
    case $monster[A.M.C. Gremlin]:
      break;
    case $monster[red herring]:
    case $monster[red snapper]:
     if (!quest_active("questL11Ron")) return "";
     break;
  }
  log("Trying to banish the " + wrap(foe) + ".");
  return banish;
}

string maybe_lta_item(monster foe)
{
  if (foe == $monster[Villainous Minion])
  {
    // Use a spy item if we have one, for the quest
    if (
      have($item[Knob Goblin firecracker])
      && !get_property("_villainLairFirecrackerUsed").to_boolean()
    )
    {
      return "item Knob Goblin firecracker";
    }

    if (
      have($item[spider web])
      && !get_property("_villainLairWebUsed").to_boolean()
    )
    {
      return "item spider web";
    }

    if (
      have($item[razor-sharp can lid])
      && !get_property("_villainLairCanLidUsed").to_boolean()
    )
    {
      return "item razor-sharp can lid";
    }
  }
  return "";
}

string maybe_run(monster foe)
{
  // check for spooky jellied to see if we want to run so we defeat someone else?
  return "";
}

string maybe_latte(monster foe)
{
  if (get_property("_latteBanishUsed") == "false") return "";
  if (get_property("_latteCopyUsed") == "false") return "";

  if (my_mp() < (my_maxmp() / 2) || my_hp() < (my_maxhp() / 2))
    return "skill gulp latte";

  return "";
}

string maybe_hug(monster foe)
{
  if (!have_skill($skill[hugs and kisses!])) return "";

  debug("Missing logic to decide if we should use the skill: " + wrap($skill[hugs and kisses!]));
  return "";
}

string maybe_portscan(monster foe)
{
  if (!have_skill($skill[portscan])) return "";

  // this skill isn't really optimal, so skip if we're trying to be hardcore:
  if (to_boolean(setting("aggressive_optimize"))) return true;

  // if we can't, the skill shouldn't show up, but an easy safeguard:
  if (portscans_remaining() < 1) return "";

  if (my_mp() < mp_cost($skill[portscan]) * 3) return "";

  // skip if we won't easily kill the current monster - there'll be other opportunities:
  if (expected_damage(foe) > my_hp() * 4) return "";

  monster scanned = $monster[government agent];
  if (my_path() == "The Source") scanned = $monster[source agent];
  if (dangerous(scanned)) return "";

  return "skill portscan";
}

string maybe_sharpen(monster foe)
{
  monster sharp = to_monster(get_property("_newYouQuestMonster"));
  if (sharp != foe) return "";
  if (to_boolean(get_property("_newYouQuestCompleted"))) return "";

  int last_sharp = to_int(setting("newyou_last_sharp", "0"));
  if (last_sharp == turns_played()) return "";

  save_daily_setting("newyou_last_sharp", turns_played());
  return "skill " + get_property("_newYouQuestSkill");
}

string yz_consult(int round, string mob, string text)
{
  // do something like this if we want to consider stealing, but WHAM should take care of this for us generally.
  // We *should* defer to WHAM when we can steal even when we want to do something else though
  // (say, steal before digitize, when applicable). Maybe send to WHAM when we have the option to steal?
//  if(contains_text(text, "value=\"steal"))  return "try to steal an item";

  monster foe = to_monster(mob);

  string maybe = maybe_run(foe);
  if (maybe != "") return maybe;

  if (round == 1)
  {
    maybe = maybe_hug(foe);
    if (maybe != "") return maybe;
  }

  maybe = maybe_extract(foe);
  if (maybe != "") return maybe;

  maybe = maybe_banish(foe);
  if (maybe != "") return maybe;

  maybe = maybe_attract(foe);
  if (maybe != "") return maybe;

  maybe = maybe_duplicate(foe);
  if (maybe != "") return maybe;

  maybe = maybe_yellow_ray(foe);
  if (maybe != "") return maybe;

  maybe = maybe_shadow(foe);
  if (maybe != "") return maybe;

  maybe = maybe_portscan(foe);
  if (maybe != "") return maybe;

  maybe = maybe_lta_item(foe);
  if (maybe != "") return maybe;

  maybe = maybe_sharpen(foe);
  if (maybe != "") return maybe;

  maybe = maybe_latte(foe);
  if (maybe != "") return maybe;

  return "consult WHAM.ash";
}
