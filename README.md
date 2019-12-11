# Description

This mod adds the following:

- Pawn Runs

# Installation
Add to resource folder `[esx]` or `[disc]`

Start using `start dazed-pawn`

# Steps

- Insert pawn Items into `essentialmode.items` table on your database
- Configure with your pawn items

# Usage
1. Go to start location
2. Pay the price
4. Get Random Locations to deliver to sent by phone for specific item

# Configuration

Pawn Items
```
{ 
    name = 'Jewels', --Name of Drug
    item = 'jewels', --Name of Item
    price = { 
        500,
        2000
    } 
}
```

Price to Pay for Starting Run
```
Config.StartPrice = 1
```

Police/Jounalist Notification Percentage
```
Config.NotifyCopsPercentage = 20 
Config.NotifyNewsPercentage = 20
```

Pawn Open/Closed hours
```
Config.openH = 7
Config.closeH = 22
```

Pawn list timeout in seconds
```
Config.Timeout = 60
```

Special Reward Item/Percentage
```
Config.rewardChance = 10
Config.Reward = {'WEAPON_SNSPISTOL', 'joint', 'opium_pooch'}  --More Items can easily be added or removed for a greater variety
```

Starting Points
```
Config.StartingPoints --List of Starting Points
```

Delivery Points
```
Config.DeliveryPoints --List of Delivery Points
```

# Requirements

- [Disc-Base](https://github.com/DiscworldZA/gta-resources/tree/master/disc-base)
- [Disc-GcPhone](https://github.com/DiscworldZA/gta-resources/tree/master/disc-gcphone)
- [progressBars](https://github.com/torpidity/progressBars)


# To Do

- Add NPC to accept pawn at location
