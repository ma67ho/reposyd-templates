/* reposyd-reportblock-header */
/* eslint-disable no-useless-constructor */
const { ReportFramework, Utils } = require('@reposyd/core')
const Rule = require('js-rules-engine').Rule
/* reposyd-reportblock-header */

class ReportBlockStakeholder extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    this.definition = {
      tt: this.designDataObjectDefinition('TT')
    }
    /* reposyd-reportblock-constructor */
  }

  /* reposyd-reportblock-body */
  buildRequirementList (settings) {
    var requirements = []
    var rule = new Rule({
      or: [{
        fact: 'attributes.type',
        operator: 'in',
        value: [settings.reportblock['rt.attributes.type']]
      }]
    })
    this.designDataObjects('RT').forEach(rt => {
      if (rule === null) {
        requirements.push(rt)
      } else {
        var match = rule.evaluate(rt)
        if (match) {
          requirements.push(rt)
        } else {}
      }
    })
    return requirements
  }

  renderContent () {
    this.format.writeHtml(this.section.text)
    if (this.section.reportblock.options.reportblock.settings.verification !== undefined && this.section.reportblock.options.reportblock.settings.verification) {
      this.renderRequirementsAndVerification()
    } else {
      this.renderRequirementsOnly()
    }
  }

  renderRequirement (rt) {
    this.addToDescribedObjects(rt)
    this.writeHtml(rt.attributes.number + ' ' + rt.attributes.title, 'title')
    this.writeHtml('Anforderung', 'title')
    this.writeHtml(rt.attributes.description, 'description')
    this.writeHtml('Begründung', 'title')
    if (!this.writeHtml(rt.attributes.rationale, 'description')) {
      this.writeHtml('Keine', 'description')
    }
    this.writeHtml('Weitere Informationen', 'title')
    var table = new ReportFramework.ReportTable.Table(2, 4)
    table.style = ReportFramework.ReportTable.Table.NoBorderStyle
    table.setData(0, 0, 'Reifegrad')
    table.setData(0, 1, 'Priorität')
    table.setData(0, 2, 'PUID')
    table.setData(0, 3, 'External ID')
    table.setData(1, 0, rt.definition.attributes.maturitylevel.properties.enumeration.find(item => item.key === rt.attributes.maturitylevel).value)
    table.setData(1, 1, rt.definition.attributes.priority.properties.enumeration.find(item => item.key === rt.attributes.priority).value)
    table.setData(1, 2, rt.puid)
    table.setData(1, 3, '')
    this.writeTable(table)
  }

  renderVerification (tt) {
    this.addToDescribedObjects(tt)
    this.writeHtml('Abnnahmetest', 'title')
    this.writeHtml('Methode: ' + this.definition.tt.attributes.method.properties.enumeration.find(item => item.key === tt.attributes.method).value)
    this.writeHtml('Umfang: ' + this.definition.tt.attributes.scope.properties.enumeration.find(item => item.key === tt.attributes.scope).value)
    this.writeHtml('Abnahmekriterium', 'title')
    this.writeHtml(tt.attributes.acceptancecriteria, 'description')
    this.writeHtml('Testbeschreibung', 'title')
    this.writeHtml(tt.attributes.description, 'description')
  }

  renderRequirementsOnly () {
    var rule = new Rule({
      or: [{
        fact: 'attributes.type',
        operator: 'in',
        value: [this.section.reportblock.options.reportblock['rt.attributes.type']]
      }]
    })
    var list = []
    this.designDataObjects('RT').forEach(rt => {
      if (rule === null) {
        list.push(rt)
      } else {
        var match = rule.evaluate(rt)
        if (match) {
          list.push(rt)
        } else {
        }
      }
    })
    list.forEach(rt => {
      this.addToDescribedObjects(rt)
      this.writeHtml(rt.attributes.number + ' ' + rt.attributes.title, 'title')
      this.writeHtml('Anforderung', 'title')
      this.writeHtml(rt.attributes.description, 'description')
      this.writeHtml('Begründung', 'title')
      if (!this.writeHtml(rt.attributes.rationale, 'description')) {
        this.writeHtml('Keine', 'description')
      }
      this.writeHtml('Weitere Informationen', 'title')
      var table = new ReportFramework.ReportTable.Table(2, 4)
      table.style = ReportFramework.ReportTable.Table.NoBorderStyle
      table.setData(0, 0, 'Reifegrad')
      table.setData(0, 1, 'Priorität')
      table.setData(0, 2, 'PUID')
      table.setData(0, 3, 'External ID')
      table.setData(1, 0, rt.definition.attributes.maturitylevel.properties.enumeration.find(item => item.key === rt.attributes.maturitylevel).value)
      table.setData(1, 1, rt.definition.attributes.priority.properties.enumeration.find(item => item.key === rt.attributes.priority).value)
      table.setData(1, 2, rt.puid)
      table.setData(1, 3, '')
      this.writeTable(table)
    })
  }

  renderRequirementsAndVerification () {
    var rule = new Rule({
      or: [{
        fact: 'attributes.type',
        operator: 'in',
        value: [this.section.reportblock.options.reportblock['rt.attributes.type']]
      }]
    })
    var list = []
    this.designDataLinks('RT', 'verifiedby', 'TT').forEach(item => {
      if (rule === null) {
        list.push(item)
      } else {
        var match = rule.evaluate(item.ddo)
        if (match) {
          list.push(item)
        }
      }
    })
    list.sort((a, b) => Utils.LexicographicalOrder.compare(a.ddo.attributes.number, b.ddo.attributes.number))
    list.forEach(item => {
      this.renderRequirement(item.ddo)
      item.ddl.forEach(link => {
        this.renderVerification(link.ddo)
      })
    })
  }

  /* reposyd-reportblock-body */
  static DefaultSettings () {
    return {
      /* reposyd-reportblock-settings */
      section: [
        {
          id: 'pageBreak',
          title: {
            'de-DE': 'Seitenumbruch',
            'en-US': 'Page Break'
          },
          type: 'boolean',
          value: false
        }
      ],
      reportblock: [
        {
          id: 'rt.attributes.type',
          title: {
            'de-DE': 'Art der Anforderung',
            'en-US': 'Type of Requirement'
          },
          type: 'select',
          options: 'type@RT',
          selection: 'single',
          value: 'pending'
        },
        {
          id: 'verification',
          title: {
            'de-DE': 'Drucke Nachweisführung',
            'en-US': 'Print Verification'
          },
          type: 'boolean',
          value: false
        }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockStakeholder
