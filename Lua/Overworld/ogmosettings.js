function hook() {
    let directionEnum = [
        "up",
        "right",
        "down",
        "left"
    ]

    return {
      beforeLoadLevel: (project, data) => {
        for (let layer of data.layers) {
            if (!layer.entities) continue;
            for (let entity of layer.entities) {
                if (!entity.values) continue;
                if (!(typeof entity.values.direction === 'number')) continue;
                var index = Math.floor(entity.values.direction)
                entity.values.direction = directionEnum[index];
              }
          }
        return data;
      },
  
      beforeSaveLevel: (project, data) => {
        for (let layer of data.layers) {
            if (!layer.entities) continue;
            for (let entity of layer.entities) {
                if (!entity.values) continue;
                if (!(typeof entity.values.direction === 'string')) continue;
                entity.values.direction = directionEnum.indexOf(entity.values.direction);
              }
          }
        return data;
      },
  
      beforeSaveProject: (project, data) => {
        return data;
      }
    }
  }
  
  hook();