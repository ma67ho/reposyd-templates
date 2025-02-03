/* reposyd-reportblock-header */
const { ReportFramework, Utils } = require('@reposyd/core')
const Rule = require('js-rules-engine').Rule
/* reposyd-reportblock-header */
class ReportBlockRequirements extends ReportFramework.ReportBlock {
  constructor (section, engine) {
    super(section, engine)
    /* reposyd-reportblock-constructor */
    this.definition = {
      tt: this.designDataObjectDefinition('TT')
    }
    /* reposyd-reportblock-constructor */
    this.translations =
    /* reposyd-reportblock-translations */
    {
      de: {
        acceptancecriterion: 'Abnahmekriterium',
        acceptancetest: 'Abnahmetest',
        additionalinformation: 'Weitere Informationen',
        externalid: 'Externe ID',
        maturitylevel: 'Reifegrad',
        method: 'Methode',
        none: 'Keine',
        priority: 'Priorität',
        puid: 'PUID',
        rationale: 'Begründung',
        requirement: 'Anforderung',
        scope: 'Umfang'
      },
      en: {
        acceptancecriterion: 'Acceptance Criterion',
        acceptancetest: 'Acceptance Test',
        additionalinformation: 'Additional Information',
        externalid: 'External ID',
        maturitylevel: 'Maturity Level',
        method: 'Method',
        none: 'None',
        priority: 'Priority',
        puid: 'PUID',
        rationale: 'Rationale',
        requirement: 'Requirement',
        scope: 'Scope'
      }
    } /* reposyd-reportblock-translations */
  }

  /* reposyd-reportblock-body */
  renderContent () {
    this.format.writeHtml(this.section.text)
    if (this.section.reportblock.options.reportblock !== undefined && this.section.reportblock.options.reportblock.verification) {
      this.renderRequirementsAndVerification()
    } else {
      this.renderRequirementsOnly()
    }
  }

  renderRequirement (sectionNumber, rt, pageBreak) {
    this.addDesignData('ddo', rt.uuid)
    this.writeHtml(sectionNumber.toString() + ' ' + rt.attributes.title + ' (' + rt.attributes.number + ')', 'title')
    if (pageBreak) {
      this.insertPageBreak()
    }
    this.writeHtml(this.tc('requirement'), 'title')
    this.writeHtml(rt.attributes.description, 'description')
    this.writeHtml(this.tc('rationale'), 'title ')
    if (!this.writeHtml(rt.attributes.rationale, 'description')) {
      this.writeHtml(this.tc('none'), 'description')
    }
    this.writeHtml(this.tc('additionalinformation'), 'title')
    var table = new ReportFramework.ReportTable.Table(1, 4)
    table.horizontalHeader.setStyle(-1, 'tableHeader')
    table.horizontalHeader.addRow()
    table.horizontalHeader.setCaption(0, this.tc('maturitylevel'))
    table.horizontalHeader.setCaption(1, this.tc('priority'))
    table.horizontalHeader.setCaption(2, this.tc('puid'))
    table.horizontalHeader.setCaption(3, this.tc('externalid'))
    table.style = ReportFramework.ReportTable.Table.NoBorderStyle

    table.setData(0, 0, rt.definition.attributes.maturitylevel.properties.enumeration.find(item => item.key === rt.attributes.maturitylevel).value[[this.document.lang]])
    table.setData(0, 1, rt.definition.attributes.priority.properties.enumeration.find(item => item.key === rt.attributes.priority).value[[this.document.lang]])
    table.setData(0, 2, rt.puid)
    table.setData(0, 3, '')
    this.writeTable(table)
  }

  renderVerification (tt) {
    this.addDesignData('ddo', tt.uuid)
    this.writeHtml(this.tc('acceptancetest'), 'title')
    this.writeHtml(this.tc('method') + ': ' + this.definition.tt.attributes.method.properties.enumeration.find(item => item.key === tt.attributes.method).value[[this.document.lang]])
    this.writeHtml(this.tc('scope') + ': ' + this.definition.tt.attributes.scope.properties.enumeration.find(item => item.key === tt.attributes.scope).value[[this.document.lang]])
    this.writeHtml(this.tc('acceptancecriterion'), 'title')
    this.writeHtml(tt.attributes.acceptancecriteria, 'description')
    //    this.writeHtml('Testbeschreibung', 'title')
    //    this.writeHtml(tt.attributes.description, 'description')
  }

  renderRequirementsOnly () {
    const list = this.requirements()
    const sectionNumber = new Utils.LexicographicalOrder.SectionNumber(this.section.number)
    sectionNumber.add()
    if (list.length === 0) {

    } else {
      list.forEach(rt => {
        this.renderRequirement(sectionNumber, rt, list[0].uuid !== rt.uuid)
        sectionNumber.inc()
      })
    }
  }

  renderRequirementsAndVerification () {
    const sectionNumber = new Utils.LexicographicalOrder.SectionNumber(this.section.number)
    sectionNumber.add()
    const list = this.requirements()
    list.forEach(rt => {
      const tests = this.designData.designDataLinks(rt, 'verifiedby', 'TT')
      this.renderRequirement(sectionNumber, rt, list[0].uuid !== rt.uuid)
      if (tests.length === 0) {
        this.writeHtml('Abnahmetest nicht definiert', 'title')
      } else {
        tests.forEach(link => {
          this.renderVerification(link.ddo)
        })
      }
      sectionNumber.inc()
    })
  }

  requirements () {
    var rule = new Rule({
      or: [{
        fact: 'attributes.type',
        operator: 'in',
        value: [this.section.reportblock.options.reportblock['rt.attributes.type']]
      }]
    })
    var list = []
    if (this.section.reportblock.options.reportblock.systemelement && this.section.reportblock.options.reportblock.systemelement !== 'none') {
      const se = this.designData.designDataObject(this.section.reportblock.options.reportblock.systemelement)
      this.designData.designDataLinks(se, 'drives', 'RT').forEach(link => {
        if (rule === null) {
          list.push(link.ddo)
        } else {
          var match = rule.evaluate(link.ddo)
          if (match) {
            list.push(link.ddo)
          } else { }
        }
      })
    } else {
      this.designDataObjects('RT').forEach(rt => {
        if (rule === null) {
          list.push(rt)
        } else {
          var match = rule.evaluate(rt)
          if (match) {
            list.push(rt)
          } else { }
        }
      })
    }
    list.sort((a, b) => Utils.LexicographicalOrder.compare(a.attributes.number, b.attributes.number))
    return list
  }

  /* reposyd-reportblock-body */
  static RuleDefinition (settings) {
    /* reposyd-reportblock-rules */
    return {
      or: [
        {
          fact: 'attributes.type',
          operator: 'in',
          value: [settings.reportblock['rt.attributes.type']]
        }
      ]
    }
    /* reposyd-reportblock-rules */
  }

  static DefaultSettings () {
    return {
      /* reposyd-reportblock-settings */
      section: [{
        id: 'pageBreak',
        title: {
          'de-DE': 'Seitenumbruch',
          'en-US': 'Page Break'
        },
        type: 'boolean',
        value: false
      }],
      reportblock: [{
        id: 'rt.attributes.type',
        title: {
          'de-DE': 'Art der Anforderung',
          'en-US': 'Type of Requirement'
        },
        type: 'select.attribute',
        dda: {
          ddo: 'RT',
          id: 'type',
          selection: 'single'
        },
        value: 'pending'
      },
      {
        id: 'systemelement',
        title: {
          'de-DE': 'Systemelement',
          'en-US': 'System Element'
        },
        type: 'select.ddo',
        ddo: {
          id: 'SE',
          selection: 'single'
        },
        value: 'none'
      },
      {
        id: 'verification',
        title: {
          'de-DE': 'Nachweisführung drucken',
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
module.exports = ReportBlockRequirements
