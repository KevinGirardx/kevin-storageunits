return {
    textUi = 'jg', -- jg, qb, ox
    notify = 'ox', -- ox, qb
    progressBar = 'ox_circle', -- ox_circle, ox_bar
    minigame = 'ox', -- ox
    target = {
        resource = 'ox', -- ox, qb, interact ( if using interact remove all the coords below the top section in the crates table)
        distance = 3.0,
    },

    storageUnits = {
        [1] = {
            cost = 5000,
            inventory = {
                slots = 10,
                maxWeight = 150000,
                label = 'Storage Unit 1',
            },
            coords = vector4(-44.00, -1232.85, 29.60, 89.99),
        },
        [2] = {
            cost = 5000,
            inventory = {
                slots = 10,
                maxWeight = 150000,
                label = 'Storage Unit 2',
            },
            coords = vector4(-44.0, -1239.23, 29.72, 89.99),
        },
        [3] = {
            cost = 5000,
            inventory = {
                slots = 10,
                maxWeight = 150000,
                label = 'Storage Unit 3',
            },
            coords = vector4(-64.9, -1224.47, 29.13, 51.0),
        },
        [4] = {
            cost = 5000,
            inventory = {
                slots = 10,
                maxWeight = 150000,
                label = 'Storage Unit 4',
            },
            coords = vector4(-70.56, -1231.53, 29.28, 51.0),
        },
        [5] = {
            cost = 5000,
            inventory = {
                slots = 10,
                maxWeight = 150000,
                label = 'Storage Unit 5',
            },
            coords = vector4(-70.84, -1243.02, 29.45, 180.0),
        },
        [6] = {
            cost = 5000,
            inventory = {
                slots = 10,
                maxWeight = 150000,
                label = 'Storage Unit 6',
            },
            coords = vector4(-54.25, -1212.38, 29.05, -43.0),
        },
        [7] = {
            cost = 5000,
            inventory = {
                slots = 10,
                maxWeight = 150000,
                label = 'Storage Unit 7',
            },
            coords = vector4(-59.57, -1207.06, 28.79, -43.0),
        },
    }
}