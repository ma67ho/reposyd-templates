const fs = require( 'fs')
const path =  require('path')
// const readConfigFile = require('../../readConfigFile')

function readConfigFile (filename) {
  // if (fs.existsSync(filename)) {
    const buffer = fs.readFileSync(filename, 'utf-8')
    return JSON.parse(buffer.toString())
  // } else {
  //   return null
  // }
}

/**
 * @param  {} db
 * @param  {} mbuuid
 * @param  {} folder
 * @since 0.1.0
 * @memberof module:CommonHelper/Repository/Template
 */
function read (fileName) {
  const definition = {
    accesscontrol: {
      assignments: {},
      roles: {},
      teams: {}
    },
    metamodel: {
      ddl: [],
      ddo: []
    },
    settings: [],
    solutionspaces: [],
    teams: []
  }
  fileName = path.resolve(fileName)
  const content = readConfigFile(fileName)
  if (content.reposyd === undefined) {
    throw new Error("entry 'reposyd' not found")
  }
  if (content.reposyd.templates === undefined) {
    throw new Error("entry 'reposyd.template' not found")
  }
  const t = {}
  content.reposyd.templates.forEach(template => {
    const folder = path.join(path.dirname(fileName), template.folder)
    let data = readConfigFile(path.join(folder, 'accesscontrol/assignments.json'))
    if (data !== null) {
      definition.accesscontrol.assignments = data
    }
    data = readConfigFile(path.join(folder, 'accesscontrol/roles.json'))
    if (data !== null) {
      definition.accesscontrol.roles = data
    }
    // read config files
    template.config.forEach(config => {
      fs.readdirSync(path.join(folder, 'settings', config)).forEach(filename => {
        if (filename.endsWith('.json')) {
          const data = readConfigFile(path.join(folder, 'settings', config, filename))
          if (data !== null) {
            definition.settings.push(data)
          }
        }
      })
    })
    // read solution spaces
    // content.reposyd.template.config.forEach(config => {
    //   fs.readdirSync(path.join(folder, 'settings', config)).forEach(filename => {
    //     if (filename.endsWith('.json')) {
    //       const data = readConfigFile(path.join(folder, 'settings', config, filename))
    //       if (data !== null) {
    //         definition.settings.push(data)
    //       }
    //     }
    //   })
    // })
    fs.readdirSync(path.join(folder, 'solutionspace')).forEach((filename) => {
      if (filename.endsWith('.json')) {
        const data = readConfigFile(path.join(folder, 'solutionspace/' + filename))
        if (data !== null) {
          definition.solutionspaces.push(data)
        }
      }
    })
    fs.readdirSync(path.join(folder, 'teams')).forEach((filename) => {
      if (filename.endsWith('.json')) {
        const data = readConfigFile(path.join(folder, 'teams/' + filename))
        if (data !== null) {
          definition.teams.push(data)
        }
      }
    })

    fs.readdirSync(path.join(folder, 'metamodel/ddl')).forEach((filename) => {
      if (filename.endsWith('.json')) {
        const data = readConfigFile(path.join(folder, 'metamodel/ddl/' + filename))
        if (data !== null) {
          definition.metamodel.ddl = definition.metamodel.ddl.concat(data)
        }
      }
    })

    fs.readdirSync(path.join(folder, 'metamodel/ddo')).forEach((filename) => {
      if (filename.endsWith('.json')) {
        const data = readConfigFile(path.join(folder, 'metamodel/ddo/' + filename))
        if (data !== null) {
          definition.metamodel.ddo.push(data)
        }
      }
    })
    // console.debug(path.join(path.resolve('./dist'), `${template.id}.json`))
    const d = {
      description: template.description || { 'de-DE': '', 'en-US': ''},
      definition: definition,
      id: template.id,
      name: template.name || { 'de-DE': '', 'en-US': ''},
      reposyd: '>0.0.1',
      version: template.version || ''
    }
    console.debug(d)
    fs.writeFile(path.join(path.resolve('./dist'), `${template.id}.json`), JSON.stringify(d), 'utf-8', function(err) {
      if (err) {
        console.log(err)
      }
    })
      // t[Template.add(db, mbuuid, template, definition)] = template.id
  })

}

console.debug(read('./package.json'))
