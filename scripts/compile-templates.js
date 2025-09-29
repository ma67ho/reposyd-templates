const fs = require('fs')
const path = require('path')
const { findPackageJson, loadPackageJson } = require('package-json-from-dist')

const crc = require('crc/crc32')
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
function read () {
  const templatesFolder = path.join(path.dirname(findPackageJson(__filename)), './templates')
  const pkg = loadPackageJson(__filename)
  if (!pkg.reposyd || !Array.isArray(pkg.reposyd.templates)){
    throw new Error('stop')
  }
  console.log(templatesFolder)
  pkg.reposyd.templates.forEach(template => {
    const definition = {
      accesscontrol: {
        assignments: {},
        roles: {},
        teams: {},
        transactions: []
      },
      designdata: {
        ddl: [],
        ddo: [],
        documents: []
      },
      metamodel: {
        ddl: [],
        ddo: [],
        patch: [],
        version: null
      },
      reportengine: {
        layouts: [],
        reportBlocks: [],
        reportscripts: [],
        templates: []
      },
      settings: [],
      solutionspaces: [],
      teams: [],
      templates: {
        ddo: [],
        document: []
      },
      version: null
    }
    if (Array.isArray(template.folder)) {
      template.folder.forEach(fld => {
        let data

        const folder = path.join(templatesFolder, fld.file)
        if (folder.endsWith('*')) {
          data = []
          fs.readdirSync(folder.replace(/\*/g, '')).forEach(filename => {
            const fn = path.join(fld.file.replace(/\*/g, ''), filename)
            if (fn.endsWith('.json') && (fld.exclude === undefined || !fld.exclude.includes(filename))) {
              data.push([readConfigFile(path.join(folder.replace(/\*/g, ''), filename)), fn])
            }
          })
        } else {
          const fn = path.join(templatesFolder, fld.file)
          if (!fs.existsSync(fn)) {
            throw new Error(`file ${fn} not found`)
          }
          data = [[readConfigFile(fn), fn]]
        }
        if (data !== null) {
          switch (fld.type) {
            case 'acl.assignment':
              data.forEach(item => {
                for (const [key, value] of Object.entries(item[0])) {
                  definition.accesscontrol.assignments[key] = item[0][key]
                }
              })
              break
            case 'acl.roles':
              data.forEach(item => {
                definition.accesscontrol.roles = item[0]
              })
              break
            case 'acl.transactions':
              data.forEach(item => {
                if (Array.isArray(item[0])) {
                  console.log(`accesscontrol: ${item[0].length} transaction(s) added`)
                  definition.accesscontrol.transactions = definition.accesscontrol.transactions.concat(item[0])
                } else {
                  definition.accesscontrol.transactions = item[0]
                }
              })
              break
            case 'metamodel.ddl':
              data.forEach(item => {
                console.log(`meta model: ddl config '${item[1]}' added`)
                if (Array.isArray(item[0])) {
                  definition.metamodel.ddl = definition.metamodel.ddl.concat(item[0])
                } else {
                  definition.metamodel.ddl.push(item[0])
                }
              })
              break
            case 'metamodel.ddo':
              data.forEach(item => {
                console.log(`meta model: ddo config '${item[1]}' added`)
                definition.metamodel.ddo.push(item[0])
              })
              break
            case 'metamodel.patch':
              data.forEach(item => {
                if (Array.isArray(item[0])) {
                  definition.metamodel.patch = definition.metamodel.patch.concat(item[0])
                } else {
                  console.log(`meta model: patch '${item[1]}' added`)
                  definition.metamodel.patch.push(item[0])
                }
              })
              break
            case 'project.config':
              if (Array.isArray(data)) {
                data.forEach(item => {
                  console.log(`project: settings '${path.basename(item[1])}' added`)
                  if (Array.isArray(item[0])) {
                    for (const it of item[0]) {
                      definition.settings.push(it)
                    }
                  } else {
                    definition.settings.push(item[0])
                  }
                })
              } else {
                definition.settings.push(data)
              }
              break
            case 'project.solutionspace':
              data.forEach(item => {
                if (Array.isArray(item[0])) {
                  definition.solutionspaces = definition.solutionspaces.concat(item[0])
                } else {
                  console.log(`project: solution space definition '${item[1]}' added`)
                  definition.solutionspaces.push(item[0])
                }
              })
              break
            case 'project.team':
              data.forEach(item => {
                console.log(`project: team definition '${item[1]}' added`)
                if (Array.isArray(item[0])) {
                  definition.teams = definition.teams.concat(item[0])
                } else {
                  definition.teams.push(item[0])
                }
              })
              break
            case 'reportgenerator.layout':
              data.forEach(item => {
                console.log(`reportgenerator: layout '${item[1]}' added`)
                definition.reportengine.layouts.push(item[0])
              })
              break
            case 'reportgenerator.script':
              data.forEach(item => {
                console.log(`reportgenerator: script '${item[1]}' added`)
                const d = {
                  Definition: item[0].definition,
                  Domain: item[0].domain,
                  Id: item[0].id,
                  Label: item[0].label,
                  Options: item[0].options,
                  Type: item[0].type
                }
                d.checksum = crc(JSON.stringify(d)).toString(16)
                definition.reportengine.reportscripts.push(d)
              })
              break
            case 'template.document':
              data.forEach(item => {
                console.log(`template: document '${item[1]}' added`)
                // if (data.scope.level === 'project') {
                //   data.scope = 'project'
                // }
                definition.templates.document.push(item[0])
              })
              break
          }
        }
      })
      definition.metamodel.version = template.metamodel
      definition.version = template.version || ''
      const d = {
        description: template.description || { 'de-DE': '', 'en-US': '' },
        definition: definition,
        id: template.id,
        name: template.name || { 'de-DE': '', 'en-US': '' },
        reposyd: '>0.0.1',
        version: template.version || ''
      }

      const fn = path.join(path.resolve('./dist'), `${template.id}.json`)
      fs.writeFileSync(fn, JSON.stringify(d), 'utf-8')
    } else {
      const folder = path.join(templatesFolder, template.folder)
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
        console.log('config: ', config)
        fs.readdirSync(path.join(folder, 'settings', config)).forEach(filename => {
          if (filename.endsWith('.json')) {
            console.log('settings added: ', filename)
            const data = readConfigFile(path.join(folder, 'settings', config, filename))
            if (data !== null) {
              if (Array.isArray(data)) {
                definition.settings = definition.settings.concat(data)
              } else {
                definition.settings.push(data)
              }
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

      fs.readdirSync(path.join(folder, 'reportengine/layout')).forEach((filename) => {
        if (filename.endsWith('.json')) {
          const data = readConfigFile(path.join(folder, 'reportengine/layout', filename))
          if (data !== null) {
            console.log('layout added: ', path.join(folder, 'reportengine/layout', filename))
            definition.reportengine.layouts.push(data)
          }
        }
      })

      // const reportBlocks = readConfigFile(path.join(folder, 'reportengine/reportblock/reportblocks.json'))
      // reportBlocks.forEach(item => {
      //   const buffer = fs.readFileSync(path.join(folder, 'reportengine/reportblock', item.fileName), 'utf-8')

      //   if (buffer !== null) {
      //     item.code = buffer.toString()
      //     item.definition = ''
      //     console.log(`report block added: ${item.fileName}`)
      //     definition.reportengine.reportBlocks.push(item)
      //   }
      // })

      const reportscripts = readConfigFile(path.join(folder, 'reportengine/reportscripts/reportscripts.json'))
      if (Array.isArray(reportscripts)) {
        reportscripts.forEach(item => {
          const buffer = fs.readFileSync(path.join(folder, 'reportengine/reportscripts', `${item}.json`), 'utf-8')

          if (buffer !== null) {
            const script = JSON.parse(buffer.toString())
            // item.definition = script.definition
            // item.options = script.options
            console.log(`report script added: ${item.fileName}`)
            definition.reportengine.reportscripts.push(script)
          }
        })
      }
      fs.readdirSync(path.join(folder, 'solutionspace')).forEach((filename) => {
        if (filename.endsWith('.json')) {
          const data = readConfigFile(path.join(folder, 'solutionspace/', filename))
          if (data !== null) {
            definition.solutionspaces.push(data)
          }
        }
      })
      fs.readdirSync(path.join(folder, 'teams')).forEach((filename) => {
        if (filename.endsWith('.json')) {
          const data = readConfigFile(path.join(folder, 'teams/', filename))
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
            console.log(`meta model: ddl config '${filename}' added`)
          }
        }
      })

      fs.readdirSync(path.join(folder, 'metamodel/ddo')).forEach((filename) => {
        if (filename.endsWith('.json')) {
          const data = readConfigFile(path.join(folder, 'metamodel/ddo/' + filename))
          if (data !== null) {
            definition.metamodel.ddo.push(data)
            console.log(`meta model: ddo config '${filename}' added`)
          }
        }
      })

      if (template.templates !== undefined) {
        if (template.templates.document !== undefined) {
          template.templates.document.forEach(filename => {
            const data = readConfigFile(path.join(folder, 'templates/document/' + filename))
            if (data !== null) {
              if (data.scope.level === 'project') {
                data.scope = 'project'
              }
              definition.templates.document.push(data)
              console.log(`document template '${filename}' added`)
            }
          })
        }
      }

      definition.metamodel.version = template.metamodel
      definition.version = template.version || ''
      const d = {
        description: template.description || { 'de-DE': '', 'en-US': '' },
        definition: definition,
        id: template.id,
        name: template.name || { 'de-DE': '', 'en-US': '' },
        reposyd: '>0.0.1',
        version: template.version || ''
      }
      fs.writeFile(path.join(path.resolve('./dist'), `${template.id}.json`), JSON.stringify(d), 'utf-8', function (err) {
        if (err) {
          console.log(err)
        }
      })
    }
  })
}
read()
// read(path.join(process.cwd(), './templates/templates.json'))
