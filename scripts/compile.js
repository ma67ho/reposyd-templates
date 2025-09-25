const path = require('path')
const fs = require('fs')
const { findPackageJson, loadPackageJson } = require('package-json-from-dist')
const finder = require('find-package-json')
const { isString, isObject, isArray, isUndefined } = require('lodash')
const { crc32 } = require('crc')
const { fileURLToPath, pathToFileURL } = require('url')


function readConfigFile(filename) {
  const buffer = fs.readFileSync(filename, 'utf-8')
  return JSON.parse(buffer.toString())
}

function run() {
  // console.log(process.cwd(), finder(process.cwd()).next().filename)

  // const fn = path.join(process.cwd(), findPackageJson(process.cwd()))
  const pkg = JSON.parse(fs.readFileSync(finder(process.cwd()).next().filename).toString())
  if (!pkg.reposyd || !Array.isArray(pkg.reposyd.templates)) {
    throw new Error('stop')
  }
  const ids = process.argv.length < 3 ? pkg.reposyd.templates.map(it => it.id) : process.argv.slice(2)
  // console.log(pkg.reposyd.templates)

  ids.forEach(id => {
    const template = pkg.reposyd.templates.find(it => it.id === id)
    if (!template) {
      throw new ReferenceError(`template '${id}' undefined`)
    }
    let definition = {
      accesscontrol: {
        assignments: {},
        roles: {},
        teams: {},
        transactions: []
      },
      designdata: {
        baseline: [],
        ddl: [],
        ddo: [],
        documents: [],
        qualitygate: [],
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

    const loadTemplates = new Map()
    if (Array.isArray(template.config)) {
      template.config.forEach(item => {
        let data

        if (isObject(item)) {
          const uri = item.url.replace('{cwd}', process.cwd())
          const url = new URL(uri)
          if (url.protocol === 'file:') {
            let fn = ''
            if (url.pathname.startsWith('./') || url.pathname.startsWith('../')) {
              fn = path.join(process.cwd(), url.pathname)
            } else {
              fn = fileURLToPath(url)
            }
            if (!fs.existsSync(fn)) {
              throw new Error(`file '${fn}' not found`)
            }
            const d = JSON.parse(fs.readFileSync(fn).toString())
            if (item.type === 'project.config') {
              const items = isArray(d) ? d : [d]
              for (let i = 0; i < items.length; i++) {
                const item = items[i]
                const idx = definition.settings.findIndex(it => it.key === item.key)
                if (item.key === 'minutes.renderer.layout.default'){
                  console.log(idx, item)
                }
                if (idx === -1) {
                  definition.settings.push(item)
                } else {
                  definition.settings[idx] = item
                }
              }
            } else if (item.type === 'reportgenerator.layout') {
              const idx = definition.reportengine.layouts.findIndex(it => it.name === d.name)
              if (idx === -1) {
                definition.reportengine.layouts.push(d)
              } else {
                definition.reportengine.layouts[idx] = d
              }
            } else if (item.type === 'reportgenerator.script') {
              const idx = definition.reportengine.reportscripts.findIndex(it => it.name === d.name)
              if (idx === -1) {
                definition.reportengine.reportscripts.push(d)
              } else {
                definition.reportengine.reportscripts[idx] = d
              }
            } else if (item.type === 'designdata') {
              if (isUndefined(definition.designdata)) {
                definition.designdata = { ddo: [], ddl: [], documents: [] }
              }
              if (isUndefined(definition.designdata.ddl)) {
                definition.designdata.ddl = []
              }
              if (isArray(d)) {
                definition.designdata.ddo.push(...d.filter(it => it.MetaData.Type === 'DesignDataObject'))
                definition.designdata.ddl.push(...d.filter(it => it.MetaData.Type === 'DesignDataLink'))
              }
              // definition.designdata.push(...d)
            }
          }
        } else if (isString(item)) {
          const url = new URL(item)
          if (url.protocol === 'package:') {
            if (!url.searchParams.has('id')) {
              throw new Error('id')
            }
            if (!url.searchParams.has('type')) {
              throw new Error('type')
            }
            if (!url.searchParams.has('type')) {
              throw new Error('type')
            }
            const type = url.searchParams.get('type')
            const fn = path.join(process.cwd(), './node_modules', url.pathname, './dist', `${url.searchParams.get('id')}.json`)
            if (!fs.existsSync(fn)) {
              throw new Error(fn)
            }
            let tmpl = loadTemplates.get(fn)
            if (!tmpl) {
              tmpl = JSON.parse(fs.readFileSync(fn).toString())
              loadTemplates.set(fn, tmpl)
            }
            if (type === '*') {
              definition = tmpl.definition
              if (isUndefined(definition.designdata.baseline)){
                definition.designdata.baseline = []
              }
              if (isUndefined(definition.designdata.ddl)){
                definition.designdata.ddl = []
              }
              if (isUndefined(definition.designdata.qualitygate)){
                definition.designdata.qualitygate = []
              }
            } else if (type === 'project.config') {
              if (!url.searchParams.has('key')) {
                throw new Error('key')
              }
              const key = url.searchParams.get('key')
              const items = key.endsWith('*') ? tmpl.definition.settings.filter(it => it.key.startsWith(key.replace('*', ''))) : tmpl.definition.settings.filter(it => it.key === key)
              items.forEach(item => {
                const idx = definition.settings.findIndex(it => it.key === item.key)
                if (item.key === 'minutes.renderer.layout.default'){
                  console.log(idx, item)
                }
                if (idx === -1) {
                  definition.settings.push(item)
                } else {
                  definition.settings[idx] = item
                }
              })
            }
          }
        }
      })
      definition.metamodel.version = definition.metamodel.version || template.metamodel
      definition.version = template.version || ''
    }
    const d = {
      checkum: crc32(JSON.stringify(definition)).toString(16),
      description: template.description || { 'de-DE': '', 'en-US': '' },
      definition: definition,
      id: template.id,
      name: template.name || { 'de-DE': '', 'en-US': '' },
      reposyd: '>0.0.1',
      version: template.version || ''
    }

    console.log(template.id, d.checkum)
    fs.writeFileSync(path.join(path.resolve('./dist'), `${template.id}.json`), JSON.stringify(d), 'utf-8')

  })
}

run()
